import Cocoa
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: NSViewController {
    private var pageURL: String = ""
    private var pageTitle: String = ""

    private let appGroup = "group.com.danielensign.Brief"

    override func loadView() {
        // Create a basic view first
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 350))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Extract shared content then setup UI
        extractSharedContent { [weak self] in
            DispatchQueue.main.async {
                self?.setupUI()
            }
        }
    }

    private func extractSharedContent(completion: @escaping () -> Void) {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            completion()
            return
        }

        let group = DispatchGroup()

        for item in extensionItems {
            // Try to get URL from userInfo (Safari provides it here)
            if let userInfo = item.userInfo,
               let urlString = userInfo[NSExtensionItemAttributedContentTextKey] as? String,
               urlString.hasPrefix("http") {
                pageURL = urlString
            }
            
            // Also check attributedContentText
            if let attributedText = item.attributedContentText?.string,
               attributedText.hasPrefix("http") {
                if pageURL.isEmpty {
                    pageURL = attributedText
                }
            }
            
            guard let attachments = item.attachments else { continue }

            for attachment in attachments {
                // Try URL type
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (data, error) in
                        defer { group.leave() }
                        if let url = data as? URL {
                            if self?.pageURL.isEmpty == true {
                                self?.pageURL = url.absoluteString
                            }
                        } else if let urlData = data as? Data,
                                  let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                            if self?.pageURL.isEmpty == true {
                                self?.pageURL = url.absoluteString
                            }
                        }
                    }
                }
                
                // Try fileURL type (Safari sometimes uses this)
                if attachment.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { [weak self] (data, error) in
                        defer { group.leave() }
                        if let url = data as? URL, url.scheme == "http" || url.scheme == "https" {
                            if self?.pageURL.isEmpty == true {
                                self?.pageURL = url.absoluteString
                            }
                        }
                    }
                }

                // Try plain text
                if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] (data, error) in
                        defer { group.leave() }
                        if let text = data as? String {
                            if text.hasPrefix("http://") || text.hasPrefix("https://") {
                                if self?.pageURL.isEmpty == true {
                                    self?.pageURL = text
                                }
                            } else if self?.pageTitle.isEmpty == true {
                                self?.pageTitle = text
                            }
                        }
                    }
                }

                // Try to get title from "public.url-name"
                if attachment.hasItemConformingToTypeIdentifier("public.url-name") {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: "public.url-name", options: nil) { [weak self] (data, error) in
                        defer { group.leave() }
                        if let title = data as? String {
                            self?.pageTitle = title
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
                pageTitle = ogTitle
                return
            }
            
            // Try twitter:title
            if let twitterTitle = extractMetaContent(from: html, name: "twitter:title") {
                pageTitle = twitterTitle
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
                    pageTitle = title
                }
            }
        } catch {
            // Silently fail - we'll just use "Shared Link" as fallback
        }
    }
    
    private func extractMetaContent(from html: String, property: String) -> String? {
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

        let hostingView = NSHostingView(rootView: shareView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: view.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
                title: pageTitle.isEmpty ? "Shared Link" : pageTitle,
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

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    await MainActor.run {
                        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                    }
                } else {
                    let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                    await showErrorOnMain("API Error (\(httpResponse.statusCode)): \(responseBody)")
                }
            } else {
                await showErrorOnMain("Failed to send article")
            }

        } catch {
            await showErrorOnMain("Error: \(error.localizedDescription)")
        }
    }

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Brief"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.runModal()
    }

    private func showErrorOnMain(_ message: String) async {
        await MainActor.run {
            showError(message)
        }
    }
}
