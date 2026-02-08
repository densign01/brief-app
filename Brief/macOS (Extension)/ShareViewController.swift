import Cocoa
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

class ShareViewController: NSViewController {
    private var pageURL: String = ""
    private var pageTitle: String = ""

    private let appGroup = "group.com.danielensign.Brief"

    override func loadView() {
        // Create a basic view first
        // Height increased to 420 to prevent content cutoff with longer titles (e.g., tweets)
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 420))
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
                // Try URL type - only accept http/https schemes for security
                if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    group.enter()
                    attachment.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (data, error) in
                        defer { group.leave() }
                        if let url = data as? URL,
                           url.scheme == "http" || url.scheme == "https" {
                            if self?.pageURL.isEmpty == true {
                                self?.pageURL = url.absoluteString
                            }
                        } else if let urlData = data as? Data,
                                  let url = URL(dataRepresentation: urlData, relativeTo: nil),
                                  url.scheme == "http" || url.scheme == "https" {
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
                                // Decode HTML entities (Instagram sends encoded text)
                                self?.pageTitle = text.htmlDecoded
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
                            self?.pageTitle = title.htmlDecoded
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

        // Use ephemeral session with timeout to prevent hangs on slow/malicious servers
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        let session = URLSession(configuration: config)

        do {
            let (data, _) = try await session.data(from: url)
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

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Save to history for display in main app
                    saveToHistory(url: url, title: title)

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

    // MARK: - History Management

    /// Saves sent article to history for display in main app.
    /// Uses the same App Group storage as the main app and iOS extension.
    private func saveToHistory(url: String, title: String) {
        let defaults = UserDefaults(suiteName: appGroup)

        // Load existing history
        var history: [[String: Any]] = []
        if let data = defaults?.data(forKey: "sentHistory"),
           let decoded = try? JSONDecoder().decode([SentArticleData].self, from: data) {
            history = decoded.map { $0.toDictionary() }
        }

        // Create new article entry
        let site = URL(string: url)?.host?.replacingOccurrences(of: "www.", with: "") ?? "Unknown"
        let newArticle: [String: Any] = [
            "id": UUID().uuidString,
            "url": url,
            "title": title,
            "site": site,
            "dateSent": Date().timeIntervalSince1970
        ]

        // Insert at beginning
        history.insert(newArticle, at: 0)

        // Keep only last 100
        if history.count > 100 {
            history = Array(history.prefix(100))
        }

        // Convert back to SentArticleData and save
        let articles = history.compactMap { SentArticleData(from: $0) }
        if let encoded = try? JSONEncoder().encode(articles) {
            defaults?.set(encoded, forKey: "sentHistory")
        }
    }
}

// MARK: - History Data Model (for extension)

/// Codable model for storing sent articles in UserDefaults.
/// Matches the structure used by the main app's UserPreferences.
private struct SentArticleData: Codable {
    let id: UUID
    let url: String
    let title: String
    let site: String
    let dateSent: Date

    init?(from dict: [String: Any]) {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let url = dict["url"] as? String,
              let title = dict["title"] as? String,
              let site = dict["site"] as? String,
              let timestamp = dict["dateSent"] as? TimeInterval else {
            return nil
        }
        self.id = id
        self.url = url
        self.title = title
        self.site = site
        self.dateSent = Date(timeIntervalSince1970: timestamp)
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "url": url,
            "title": title,
            "site": site,
            "dateSent": dateSent.timeIntervalSince1970
        ]
    }
}
