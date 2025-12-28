import Foundation

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
    
    private init() {
        self.email = userDefaults.string(forKey: "email") ?? ""
        self.apiEndpoint = userDefaults.string(forKey: "apiEndpoint") ?? "https://quickcapture-api.daniel-ensign.workers.dev"
        self.aiSummaryEnabled = userDefaults.bool(forKey: "aiSummaryEnabled")
        self.summaryLength = userDefaults.string(forKey: "summaryLength") ?? "short"
    }
}