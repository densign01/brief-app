import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - URL Identifiable Extension
extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

struct ContentView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.scenePhase) private var scenePhase
    @State private var url = ""
    @State private var title = ""
    @State private var context = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSettings = false
    @State private var alertIsSuccess = false
    #if os(iOS)
    @State private var selectedArticleURL: URL?
    @State private var selectedPage = 0  // 0 = Send, 1 = History
    #endif

    var body: some View {
        #if os(iOS)
        // iOS: Two-page swipe interface
        ZStack {
            Color.briefBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Shared header with page indicator
                headerWithPageIndicator
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                // Swipeable pages
                TabView(selection: $selectedPage) {
                    sendPage
                        .tag(0)

                    historyPage
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .alert(alertIsSuccess ? "Success" : "Brief", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(userPreferences)
        }
        .sheet(item: $selectedArticleURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Refresh history when returning to foreground to pick up
            // any articles sent via Share Extension while backgrounded
            if newPhase == .active {
                userPreferences.refreshHistory()
            }
        }
        #else
        // macOS: Single page layout (no swiping)
        ZStack {
            Color.briefBackground

            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    if userPreferences.email.isEmpty {
                        setupPrompt
                    }

                    VStack(spacing: 20) {
                        urlInputSection

                        if !title.isEmpty {
                            titleDisplaySection
                        }

                        contextInputSection
                        aiSummarySection
                        sendButton
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)

                    tipSection
                }
                .padding(20)
            }
        }
        .frame(minWidth: 480, idealWidth: 520, maxWidth: 600, minHeight: 600, idealHeight: 700, maxHeight: 800)
        .alert(alertIsSuccess ? "Success" : "Brief", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(userPreferences)
        }
        #endif
    }

    // MARK: - iOS Page Views

    #if os(iOS)
    /// Header with page indicator dots
    private var headerWithPageIndicator: some View {
        VStack(spacing: 12) {
            headerSection

            // Page indicator dots
            HStack(spacing: 8) {
                Circle()
                    .fill(selectedPage == 0 ? Color.briefPrimary : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(selectedPage == 1 ? Color.briefPrimary : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }

    /// Send page content
    private var sendPage: some View {
        ScrollView {
            VStack(spacing: 24) {
                if userPreferences.email.isEmpty {
                    setupPrompt
                }

                VStack(spacing: 20) {
                    urlInputSection

                    if !title.isEmpty {
                        titleDisplaySection
                    }

                    contextInputSection
                    aiSummarySection
                    sendButton
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)

                tipSection
            }
            .padding(20)
        }
    }

    /// History page content
    private var historyPage: some View {
        ScrollView {
            VStack(spacing: 16) {
                // History header
                HStack {
                    Label("Recent", systemImage: "clock.arrow.circlepath")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(userPreferences.sentHistory.count) sent")
                        .font(.subheadline)
                        .foregroundColor(.briefSecondaryText)
                }

                if userPreferences.sentHistory.isEmpty {
                    // Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No links sent yet")
                            .font(.headline)
                            .foregroundColor(.briefSecondaryText)
                        Text("Share a link from Safari to get started")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    // History list
                    VStack(spacing: 0) {
                        ForEach(Array(userPreferences.sentHistory.enumerated()), id: \.element.id) { index, article in
                            Button(action: {
                                if let url = URL(string: article.url) {
                                    selectedArticleURL = url
                                }
                            }) {
                                historyRow(article: article)
                            }
                            .buttonStyle(PlainButtonStyle())

                            if index < userPreferences.sentHistory.count - 1 {
                                Divider()
                                    .padding(.leading, 44)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
            }
            .padding(20)
        }
    }
    #endif
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 12) {
            // App icon representation
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [.briefPrimary, .briefSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Brief")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("AI-powered link summaries")
                    .font(.subheadline)
                    .foregroundColor(.briefSecondaryText)
            }
            
            Spacer()
            
            Button(action: { showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(.briefPrimary)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Setup Prompt
    private var setupPrompt: some View {
        HStack(spacing: 12) {
            Image(systemName: "envelope.badge")
                .font(.title2)
                .foregroundColor(.briefPrimary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Set up your email")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Configure where to send your links")
                    .font(.caption)
                    .foregroundColor(.briefSecondaryText)
            }
            
            Spacer()
            
            Button("Set Up") {
                showingSettings = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.briefPrimary)
        }
        .padding(16)
        .background(Color.briefPrimary.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.briefPrimary.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - URL Input Section
    private var urlInputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("URL", systemImage: "link")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 10) {
                TextField("https://example.com", text: $url)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(Color.gray.opacity(0.08))
                    .cornerRadius(10)
                    .onSubmit {
                        analyzeURL()
                    }
                
                Button(action: pasteFromClipboard) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.briefPrimary)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(isLoading)
            }
            
            if !url.isEmpty && title.isEmpty && !isLoading {
                Button(action: analyzeURL) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Analyze URL")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.briefPrimary)
                }
            }
        }
    }
    
    // MARK: - Title Display Section
    private var titleDisplaySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Title", systemImage: "text.quote")
                .font(.caption)
                .foregroundColor(.briefSecondaryText)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .textSelection(.enabled)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color.briefPrimary.opacity(0.06), Color.briefSecondary.opacity(0.04)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.briefPrimary.opacity(0.15), lineWidth: 1)
                )
        }
    }
    
    // MARK: - Context Input Section
    private var contextInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Personal Note", systemImage: "note.text")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Optional - add context for yourself")
                .font(.caption)
                .foregroundColor(.briefSecondaryText)
            
            TextEditor(text: $context)
                .frame(height: 70)
                .padding(8)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
        }
    }
    
    // MARK: - AI Summary Section
    private var aiSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.briefPrimary)
                    Text("AI Summary")
                        .font(.headline)
                }
                
                Spacer()
                
                Toggle("", isOn: $userPreferences.aiSummaryEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: .briefPrimary))
                    .labelsHidden()
            }
            
            if userPreferences.aiSummaryEnabled {
                HStack(spacing: 12) {
                    Text("Length:")
                        .font(.subheadline)
                        .foregroundColor(.briefSecondaryText)
                    
                    Picker("", selection: $userPreferences.summaryLength) {
                        Text("Short").tag("short")
                        Text("Detailed").tag("long")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: 180)
                }
                
                Text("Powered by Gemini • Generates key bullet points")
                    .font(.caption)
                    .foregroundColor(.briefSecondaryText)
            }
        }
        .padding(14)
        .background(Color.gray.opacity(0.04))
        .cornerRadius(12)
    }
    
    // MARK: - Send Button
    private var sendButton: some View {
        Button(action: sendArticle) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                }
                Text(isLoading ? "Sending..." : "Send to Email")
                    .fontWeight(.semibold)
                Image(systemName: "paperplane.fill")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: canSend ? [.briefPrimary, .briefSecondary] : [.gray.opacity(0.4), .gray.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(canSend ? .white : .gray)
            .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!canSend)
    }
    
    private var canSend: Bool {
        !url.isEmpty && !title.isEmpty && !userPreferences.email.isEmpty && !isLoading
    }
    
    // MARK: - Tip Section
    private var tipSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.briefAccent)

            #if os(iOS)
            Text("Swipe left for history • Use Share menu for faster capture")
                .font(.caption)
                .foregroundColor(.briefSecondaryText)
            #else
            Text("Tip: Use the Share menu in Safari or other apps for faster capture")
                .font(.caption)
                .foregroundColor(.briefSecondaryText)
            #endif
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
    }

    // MARK: - History Row (shared)
    #if os(iOS)
    private func historyRow(article: SentArticle) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.title3)
                .foregroundColor(.briefPrimary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text(article.site)
                        .font(.caption)
                        .foregroundColor(.briefSecondaryText)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.briefSecondaryText)

                    Text(article.dateSent, style: .relative)
                        .font(.caption)
                        .foregroundColor(.briefSecondaryText)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
    #endif
    
    // MARK: - Actions
    private func pasteFromClipboard() {
        #if os(macOS)
        if let clipboardString = NSPasteboard.general.string(forType: .string) {
            url = clipboardString
            analyzeURL()
        }
        #else
        if let clipboardString = UIPasteboard.general.string {
            url = clipboardString
            analyzeURL()
        }
        #endif
    }
    
    private func analyzeURL() {
        guard !url.isEmpty else { return }
        
        isLoading = true
        
        Task {
            do {
                let fetchedTitle = try await fetchArticleTitle(from: url)
                await MainActor.run {
                    title = fetchedTitle
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    if let urlComponents = URLComponents(string: url),
                       let host = urlComponents.host {
                        title = host.replacingOccurrences(of: "www.", with: "")
                    } else {
                        title = "Article"
                    }
                    isLoading = false
                }
            }
        }
    }
    
    private func fetchArticleTitle(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let html = String(data: data, encoding: .utf8) ?? ""
        
        // Try og:title first (most reliable)
        if let ogMatch = html.range(of: "<meta property=\"og:title\" content=\"([^\"]+)\"", options: .regularExpression) {
            var ogTitle = String(html[ogMatch])
            ogTitle = ogTitle.replacingOccurrences(of: "<meta property=\"og:title\" content=\"", with: "")
            ogTitle = ogTitle.replacingOccurrences(of: "\"", with: "")
            if !ogTitle.isEmpty {
                return cleanTitle(ogTitle)
            }
        }
        
        // Try <title> tag
        if let titleRange = html.range(of: "<title[^>]*>([^<]+)</title>", options: .regularExpression) {
            var extractedTitle = String(html[titleRange])
            extractedTitle = extractedTitle.replacingOccurrences(of: "<title[^>]*>", with: "", options: .regularExpression)
            extractedTitle = extractedTitle.replacingOccurrences(of: "</title>", with: "")
            return cleanTitle(extractedTitle)
        }
        
        // Fallback to domain
        if let urlObj = URL(string: urlString), let host = urlObj.host {
            return host.replacingOccurrences(of: "www.", with: "")
        }
        
        return "Article"
    }
    
    private func cleanTitle(_ title: String) -> String {
        var cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let suffixes = [" - The New York Times", " | CNN", " - BBC News", " - Reuters", 
                       " - The Washington Post", " - WSJ", " | AP News", " - X"]
        for suffix in suffixes {
            if cleaned.hasSuffix(suffix) {
                cleaned = String(cleaned.dropLast(suffix.count))
                break
            }
        }
        
        return cleaned
    }
    
    private func sendArticle() {
        isLoading = true
        
        let apiService = APIService()
        
        Task {
            do {
                let success = try await apiService.sendArticle(
                    url: url,
                    title: title,
                    email: userPreferences.email,
                    context: context.isEmpty ? nil : context,
                    aiSummary: userPreferences.aiSummaryEnabled,
                    summaryLength: userPreferences.summaryLength
                )
                
                await MainActor.run {
                    isLoading = false
                    if success {
                        // Save to history
                        userPreferences.addToHistory(url: url, title: title)

                        alertMessage = "Link sent to \(userPreferences.email)"
                        alertIsSuccess = true
                        url = ""
                        title = ""
                        context = ""
                    } else {
                        alertMessage = "Failed to send link. Please try again."
                        alertIsSuccess = false
                    }
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "Error: \(error.localizedDescription)"
                    alertIsSuccess = false
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @Environment(\.dismiss) private var dismiss
    @State private var showResetConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(20)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Email Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Email Address", systemImage: "envelope.fill")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("your@email.com", text: $userPreferences.email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(14)
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(10)
                        
                        Text("Links will be sent to this address")
                            .font(.caption)
                            .foregroundColor(.briefSecondaryText)
                    }
                    
                    Divider()
                    
                    // About Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("About Brief", systemImage: "info.circle.fill")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            aboutRow(icon: "sparkles", text: "AI summaries powered by Gemini")
                            aboutRow(icon: "lock.shield", text: "Email stored locally on device")
                            aboutRow(icon: "square.and.arrow.up", text: "Use Share menu for faster capture")
                            
                            Button(action: { showResetConfirmation = true }) {
                                aboutRow(icon: "arrow.counterclockwise", text: "Reset Onboarding Flow")
                                    .foregroundColor(.briefPrimary)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 8)
                        }
                        .padding(14)
                        .background(Color.gray.opacity(0.04))
                        .cornerRadius(10)
                    }
                }
                .padding(20)
            }
        }
        #if os(macOS)
        .frame(width: 400, height: 380)
        #endif
        .confirmationDialog(
            "Reset Brief?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                userPreferences.resetAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will clear your email, send history, and settings, then restart onboarding.\n\nTo just change your email, use the Email Address field in Settings instead.")
        }
    }
    
    private func aboutRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.briefPrimary)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.briefSecondaryText)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserPreferences.shared)
}