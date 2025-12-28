import UIKit
import SwiftUI
import UniformTypeIdentifiers

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
                                self?.pageTitle = text
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
                                self?.pageTitle = title
                            }
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion()
        }
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
