import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Theme Colors
extension Color {
    static let briefPrimary = Color(red: 0.388, green: 0.275, blue: 0.878) // #6346E0 - Indigo
    static let briefSecondary = Color(red: 0.576, green: 0.333, blue: 0.914) // #9355E9 - Purple
    static let briefAccent = Color(red: 0.663, green: 0.388, blue: 0.949) // #A963F2 - Light Purple
    static let briefBackground = Color(red: 0.976, green: 0.973, blue: 0.988) // #F9F8FC - Light lavender
    static let briefSecondaryText = Color(red: 0.35, green: 0.35, blue: 0.4) // #595966 - Darker gray for accessibility
}

struct ContentView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var url = ""
    @State private var title = ""
    @State private var context = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSettings = false
    @State private var alertIsSuccess = false
    
    var body: some View {
        ZStack {
            // Background
            #if os(iOS)
            Color.briefBackground.ignoresSafeArea()
            #else
            Color.briefBackground
            #endif
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Setup prompt if needed
                    if userPreferences.email.isEmpty {
                        setupPrompt
                    }
                    
                    // Main content
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
                    
                    // Tip section
                    tipSection
                }
                .padding(20)
            }
        }
        #if os(macOS)
        .frame(minWidth: 480, idealWidth: 520, maxWidth: 600, minHeight: 600, idealHeight: 700, maxHeight: 800)
        #endif
        .alert(alertIsSuccess ? "Success" : "Brief", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(userPreferences)
        }
    }
    
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
            
            Text("Tip: Use the Share menu in Safari or other apps for faster capture")
                .font(.caption)
                .foregroundColor(.briefSecondaryText)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.8))
        .cornerRadius(10)
    }
    
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
                            
                            Button(action: { userPreferences.hasCompletedOnboarding = false }) {
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