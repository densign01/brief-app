import Foundation

// MARK: - Sent Article Model
struct SentArticle: Codable, Identifiable {
    let id: UUID
    let url: String
    let title: String
    let site: String
    let dateSent: Date

    init(url: String, title: String) {
        self.id = UUID()
        self.url = url
        self.title = title
        self.site = URL(string: url)?.host?.replacingOccurrences(of: "www.", with: "") ?? "Unknown"
        self.dateSent = Date()
    }
}

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    private let userDefaults = UserDefaults(suiteName: "group.com.danielensign.Brief") ?? UserDefaults.standard
    
    @Published var email: String {
        didSet {
            userDefaults.set(email, forKey: "email")
        }
    }
    
    @Published var apiEndpoint: String {
        didSet {
            userDefaults.set(apiEndpoint, forKey: "apiEndpoint")
        }
    }
    
    @Published var aiSummaryEnabled: Bool {
        didSet {
            userDefaults.set(aiSummaryEnabled, forKey: "aiSummaryEnabled")
        }
    }
    
    @Published var summaryLength: String {
        didSet {
            userDefaults.set(summaryLength, forKey: "summaryLength")
        }
    }

    @Published var hasAcceptedAIDataConsent: Bool {
        didSet {
            userDefaults.set(hasAcceptedAIDataConsent, forKey: "hasAcceptedAIDataConsent")
        }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet {
            userDefaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }

    @Published var sentHistory: [SentArticle] = [] {
        didSet {
            saveHistory()
        }
    }

    private init() {
        // Load history first before other properties that depend on it
        let defaults = userDefaults
        let historyData = defaults.data(forKey: "sentHistory")
        let loadedHistory: [SentArticle]
        if let data = historyData,
           let decoded = try? JSONDecoder().decode([SentArticle].self, from: data) {
            loadedHistory = decoded
        } else {
            loadedHistory = []
        }

        self.email = defaults.string(forKey: "email") ?? ""
        self.apiEndpoint = defaults.string(forKey: "apiEndpoint") ?? "https://quickcapture-api.daniel-ensign.workers.dev"
        self.aiSummaryEnabled = defaults.bool(forKey: "aiSummaryEnabled")
        self.summaryLength = defaults.string(forKey: "summaryLength") ?? "short"
        self.hasAcceptedAIDataConsent = defaults.bool(forKey: "hasAcceptedAIDataConsent")
        self.hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
        self.sentHistory = loadedHistory
    }

    // MARK: - History Management

    func addToHistory(url: String, title: String) {
        let article = SentArticle(url: url, title: title)
        var updated = sentHistory
        updated.insert(article, at: 0)

        // Keep only the last 100 articles
        if updated.count > 100 {
            updated = Array(updated.prefix(100))
        }

        sentHistory = updated  // Single assignment, single save
    }

    private func saveHistory() {
        do {
            let encoded = try JSONEncoder().encode(sentHistory)
            userDefaults.set(encoded, forKey: "sentHistory")
        } catch {
            print("[Brief] Failed to save history: \(error.localizedDescription)")
        }
    }

    private func loadHistory() -> [SentArticle] {
        guard let data = userDefaults.data(forKey: "sentHistory"),
              let decoded = try? JSONDecoder().decode([SentArticle].self, from: data) else {
            return []
        }
        return decoded
    }

    // MARK: - Refresh from Storage

    /// Reloads history from UserDefaults. Call when app returns to foreground
    /// to pick up any articles sent via the Share Extension while backgrounded.
    func refreshHistory() {
        sentHistory = loadHistory()
    }

    // MARK: - Reset All Data

    /// Clears all user data and returns app to fresh state.
    /// Used by "Reset Onboarding Flow" button in Settings.
    func resetAll() {
        hasCompletedOnboarding = false
        email = ""
        sentHistory = []
        aiSummaryEnabled = false
        summaryLength = "short"
        hasAcceptedAIDataConsent = false
    }
}
