import UIKit
import SwiftUI
import UniformTypeIdentifiers

// MARK: - HTML Entity Decoding
extension String {
    /// Decodes HTML entities like &quot;, &#x201c;, &amp; etc.
    /// Runs twice to handle double-encoded entities (e.g., LinkedIn's &amp;#39;)
    var htmlDecoded: String {
        func decodeOnce(_ input: String) -> String {
            guard let data = input.data(using: .utf8) else { return input }
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            guard let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
                return input
            }
            return attributed.string
        }

        // Decode twice to handle double-encoded entities
        let firstPass = decodeOnce(self)
        let secondPass = decodeOnce(firstPass)
        return secondPass
    }
}

class ShareViewController: UIViewController {
    private var pageURL: String = ""
    private var pageTitle: String = ""
    private var hostingController: UIHostingController<ShareView>?

    private let appGroup = "group.com.danielensign.Brief"

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        // Extract shared content
        extractSharedContent { [weak self] in
            self?.setupUI()
        }
    }

    private func extractSharedContent(completion: @escaping () -> Void) {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            completion()
            return
        }

        let group = DispatchGroup()

        for item in extensionItems {
            guard let attachments = item.attachments else { continue }

            for attachment in attachments {
                // Try URL first
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (data, error) in
                        defer { group.leave() }
                        if let url = data as? URL {
                            self?.pageURL = url.absoluteString
                        }
                    }
                }

                // Try plain text (might be a URL as text)
                if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] (data, error) in
                        defer { group.leave() }
                        if let text = data as? String {
                            // Check if it looks like a URL
                            if text.hasPrefix("http://") || text.hasPrefix("https://") {
                                if self?.pageURL.isEmpty == true {
                                    self?.pageURL = text
                                }
                            } else if self?.pageTitle.isEmpty == true {
                                // Decode HTML entities (Instagram sends encoded text)
                                self?.pageTitle = text.htmlDecoded
                            }
                        }
                    }
                }

                // Try property list for richer data
                if attachment.hasItemConformingToTypeIdentifier(UTType.propertyList.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.propertyList.identifier, options: nil) { [weak self] (data, error) in
                        defer { group.leave() }
                        if let dict = data as? [String: Any] {
                            if let urlString = dict[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: Any],
                               let url = urlString["URL"] as? String {
                                self?.pageURL = url
                            }
                            if let title = dict["title"] as? String {
                                self?.pageTitle = title.htmlDecoded
                            }
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            // If we have a URL but no title, fetch it from the page
            if let self = self, !self.pageURL.isEmpty && self.pageTitle.isEmpty {
                Task {
                    await self.fetchTitleFromURL()
                    await MainActor.run {
                        completion()
                    }
                }
            } else {
                completion()
            }
        }
    }

    private func fetchTitleFromURL() async {
        guard let url = URL(string: pageURL) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else { return }
            
            // Try og:title first (most reliable for articles)
            if let ogTitle = extractMetaContent(from: html, property: "og:title") {
                pageTitle = ogTitle.htmlDecoded
                return
            }

            // Try twitter:title
            if let twitterTitle = extractMetaContent(from: html, name: "twitter:title") {
                pageTitle = twitterTitle.htmlDecoded
                return
            }
            
            // Fall back to <title> tag
            if let titleMatch = html.range(of: "<title[^>]*>([^<]+)</title>", options: .regularExpression) {
                var title = String(html[titleMatch])
                title = title.replacingOccurrences(of: "<title[^>]*>", with: "", options: .regularExpression)
                title = title.replacingOccurrences(of: "</title>", with: "")
                title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Clean up common suffixes
                let suffixes = [" - The New York Times", " | CNN", " - BBC News", " - Reuters", 
                               " - The Washington Post", " - WSJ", " | AP News"]
                for suffix in suffixes {
                    if title.hasSuffix(suffix) {
                        title = String(title.dropLast(suffix.count))
                        break
                    }
                }
                
                if !title.isEmpty {
                    pageTitle = title.htmlDecoded
                }
            }
        } catch {
            // Silently fail - we'll just use "Shared Link" as fallback
        }
    }
    
    private func extractMetaContent(from html: String, property: String) -> String? {
        // Match: <meta property="og:title" content="Article Title">
        let pattern = "<meta[^>]+property=[\"']\(property)[\"'][^>]+content=[\"']([^\"']+)[\"']"
        if let match = html.range(of: pattern, options: .regularExpression) {
            let matchStr = String(html[match])
            if let contentMatch = matchStr.range(of: "content=[\"']([^\"']+)[\"']", options: .regularExpression) {
                var content = String(matchStr[contentMatch])
                content = content.replacingOccurrences(of: "content=[\"']", with: "", options: .regularExpression)
                content = content.replacingOccurrences(of: "[\"']$", with: "", options: .regularExpression)
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Try alternate order: content before property
        let altPattern = "<meta[^>]+content=[\"']([^\"']+)[\"'][^>]+property=[\"']\(property)[\"']"
        if let match = html.range(of: altPattern, options: .regularExpression) {
            let matchStr = String(html[match])
            if let contentMatch = matchStr.range(of: "content=[\"']([^\"']+)[\"']", options: .regularExpression) {
                var content = String(matchStr[contentMatch])
                content = content.replacingOccurrences(of: "content=[\"']", with: "", options: .regularExpression)
                content = content.replacingOccurrences(of: "[\"']$", with: "", options: .regularExpression)
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return nil
    }
    
    private func extractMetaContent(from html: String, name: String) -> String? {
        // Match: <meta name="twitter:title" content="Article Title">
        let pattern = "<meta[^>]+name=[\"']\(name)[\"'][^>]+content=[\"']([^\"']+)[\"']"
        if let match = html.range(of: pattern, options: .regularExpression) {
            let matchStr = String(html[match])
            if let contentMatch = matchStr.range(of: "content=[\"']([^\"']+)[\"']", options: .regularExpression) {
                var content = String(matchStr[contentMatch])
                content = content.replacingOccurrences(of: "content=[\"']", with: "", options: .regularExpression)
                content = content.replacingOccurrences(of: "[\"']$", with: "", options: .regularExpression)
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }

    private func setupUI() {
        let shareView = ShareView(
            url: pageURL,
            pageTitle: pageTitle,
            onSend: { [weak self] context, aiSummary, summaryLength in
                self?.sendArticle(context: context, aiSummary: aiSummary, summaryLength: summaryLength)
            },
            onCancel: { [weak self] in
                self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
        )

        let hostingController = UIHostingController(rootView: shareView)
        self.hostingController = hostingController

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    private func sendArticle(context: String?, aiSummary: Bool, summaryLength: String) {
        // Get email from shared preferences
        let defaults = UserDefaults(suiteName: appGroup)
        guard let email = defaults?.string(forKey: "email"), !email.isEmpty else {
            showError("Please set your email in the Brief app first")
            return
        }

        let apiEndpoint = defaults?.string(forKey: "apiEndpoint") ?? "https://quickcapture-api.daniel-ensign.workers.dev"

        Task {
            await performSend(
                url: pageURL,
                title: pageTitle,
                email: email,
                apiEndpoint: apiEndpoint,
                context: context,
                aiSummary: aiSummary,
                summaryLength: summaryLength
            )
        }
    }

    private func performSend(
        url: String,
        title: String,
        email: String,
        apiEndpoint: String,
        context: String?,
        aiSummary: Bool,
        summaryLength: String
    ) async {
        do {
            guard let apiURL = URL(string: apiEndpoint) else {
                await showErrorOnMain("Invalid API URL")
                return
            }

            let site = URL(string: url)?.host ?? ""

            var requestBody: [String: Any] = [
                "url": url,
                "title": title,
                "site": site,
                "email": email,
                "aiSummary": aiSummary,
                "summaryLength": summaryLength
            ]

            if let context = context {
                requestBody["context"] = context
            }

            var request = URLRequest(url: apiURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                await MainActor.run {
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
            } else {
                await showErrorOnMain("Failed to send article")
            }

        } catch {
            await showErrorOnMain("Error: \(error.localizedDescription)")
        }
    }

    private func showError(_ message: String) {
        // Update the SwiftUI view to show error
        // For now, use an alert
        let alert = UIAlertController(title: "Brief", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showErrorOnMain(_ message: String) async {
        await MainActor.run {
            showError(message)
        }
    }
}
