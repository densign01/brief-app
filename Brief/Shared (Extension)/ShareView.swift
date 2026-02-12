import SwiftUI

// MARK: - Theme Colors (Shared Extension)
private extension Color {
    static let briefPrimary = Color(red: 0.388, green: 0.275, blue: 0.878) // #6346E0 - Indigo
    static let briefSecondary = Color(red: 0.576, green: 0.333, blue: 0.914) // #9355E9 - Purple
    static let briefSecondaryText = Color(red: 0.35, green: 0.35, blue: 0.4) // #595966 - Darker gray for accessibility
}

/// Shared SwiftUI view for the Share Extension
/// Works on both iOS and macOS
struct ShareView: View {
    let url: String
    let pageTitle: String
    let onSend: (String?, Bool, String) -> Void  // context, aiSummary, summaryLength
    let onCancel: () -> Void

    @State private var context = ""
    @State private var aiSummaryEnabled: Bool
    @State private var summaryLength: String
    @State private var hasAcceptedAIConsent: Bool
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAIConsentSheet = false

    private let appGroup = "group.com.danielensign.Brief"

    init(url: String, pageTitle: String, onSend: @escaping (String?, Bool, String) -> Void, onCancel: @escaping () -> Void) {
        self.url = url
        self.pageTitle = pageTitle
        self.onSend = onSend
        self.onCancel = onCancel

        // Load preferences from app group
        let defaults = UserDefaults(suiteName: "group.com.danielensign.Brief")
        _aiSummaryEnabled = State(initialValue: defaults?.bool(forKey: "aiSummaryEnabled") ?? false)
        _summaryLength = State(initialValue: defaults?.string(forKey: "summaryLength") ?? "short")
        _hasAcceptedAIConsent = State(initialValue: defaults?.bool(forKey: "hasAcceptedAIDataConsent") ?? false)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            Divider()
            
            // Content (no scroll needed for compact layout)
            VStack(spacing: 12) {
                articleInfoSection
                contextInputSection
                aiSummarySection

                if let error = errorMessage {
                    errorSection(error)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            Divider()
            
            // Footer with send button
            sendButtonSection
        }
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .onExitCommand {
            onCancel()
        }
        .background(
            Button("") {
                performSend()
            }
            .keyboardShortcut(.return, modifiers: .command)
            .hidden()
        )
        #endif
    }
    
    private func performSend() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        onSend(
            context.isEmpty ? nil : context,
            aiSummaryEnabled,
            summaryLength
        )
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            HStack(spacing: 10) {
                // Mini app icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            colors: [.briefPrimary, .briefSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "doc.text.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                Text("Brief")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray.opacity(0.6))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
    
    // MARK: - Article Info
    private var articleInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Link", systemImage: "link")
                .font(.caption)
                .foregroundColor(.briefSecondaryText)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(pageTitle.isEmpty ? "Shared Link" : pageTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                Text(url)
                    .font(.caption)
                    .foregroundColor(.briefPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
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
    
    // MARK: - Context Input
    private var contextInputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Personal Note", systemImage: "note.text")
                .font(.caption)
                .foregroundColor(.briefSecondaryText)

            #if os(iOS)
            TextField("Add a note for yourself...", text: $context, axis: .vertical)
                .lineLimit(2...4)
                .padding(12)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(10)
            #else
            TextField("Add a note...", text: $context)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(10)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(10)
            #endif
        }
    }
    
    // MARK: - AI Summary Section
    private var aiSummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.briefPrimary)
                        .font(.caption)
                    Text("AI Summary")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { aiSummaryEnabled },
                    set: { newValue in
                        if newValue && !hasAcceptedAIConsent {
                            // Show consent sheet before enabling
                            showingAIConsentSheet = true
                        } else {
                            aiSummaryEnabled = newValue
                            savePreference(key: "aiSummaryEnabled", value: newValue)
                        }
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .briefPrimary))
                .labelsHidden()
            }

            if aiSummaryEnabled {
                Picker("Length", selection: $summaryLength) {
                    Text("Short").tag("short")
                    Text("Detailed").tag("long")
                }
                .pickerStyle(.segmented)
                .onChange(of: summaryLength) { _, newValue in
                    savePreference(key: "summaryLength", value: newValue)
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.04))
        .cornerRadius(10)
        .sheet(isPresented: $showingAIConsentSheet) {
            ShareExtensionAIConsentSheet(
                onAccept: {
                    hasAcceptedAIConsent = true
                    aiSummaryEnabled = true
                    savePreference(key: "hasAcceptedAIDataConsent", value: true)
                    savePreference(key: "aiSummaryEnabled", value: true)
                    showingAIConsentSheet = false
                },
                onDecline: {
                    showingAIConsentSheet = false
                }
            )
        }
    }
    
    // MARK: - Error Section
    private func errorSection(_ error: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(error)
                .font(.caption)
                .foregroundColor(.red)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08))
        .cornerRadius(10)
    }
    
    // MARK: - Send Button
    private var sendButtonSection: some View {
        VStack(spacing: 8) {
            Button(action: performSend) {
                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.85)
                    }
                    Text(isLoading ? "Sending..." : "Send to Email")
                        .fontWeight(.semibold)
                    if !isLoading {
                        Image(systemName: "paperplane.fill")
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: isLoading ? [.gray.opacity(0.4), .gray.opacity(0.3)] : [.briefPrimary, .briefSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(isLoading ? .gray : .white)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isLoading)
            
            #if os(macOS)
            Text("⌘ Return to send")
                .font(.caption2)
                .foregroundColor(.briefSecondaryText)
            #endif
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func savePreference(key: String, value: Any) {
        UserDefaults(suiteName: appGroup)?.set(value, forKey: key)
    }

    func showError(_ message: String) {
        isLoading = false
        errorMessage = message
    }
}

// MARK: - AI Consent Sheet for Share Extension
struct ShareExtensionAIConsentSheet: View {
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.briefPrimary.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundColor(.briefPrimary)
                }

                Text("AI Summary")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("Data Sharing Disclosure")
                    .font(.caption)
                    .foregroundColor(.briefSecondaryText)
            }
            .padding(.top, 16)

            // Disclosure content
            VStack(alignment: .leading, spacing: 12) {
                disclosureRow(
                    icon: "doc.text",
                    title: "What's shared",
                    description: "Link URL and webpage content"
                )

                disclosureRow(
                    icon: "building.2",
                    title: "Who receives it",
                    description: "Google Gemini for summary generation"
                )

                disclosureRow(
                    icon: "hand.raised",
                    title: "What's not shared",
                    description: "Your email and personal notes"
                )
            }
            .padding(16)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)

            Spacer()

            // Buttons
            VStack(spacing: 10) {
                Button(action: onAccept) {
                    Text("Enable AI Summary")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.briefPrimary, .briefSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: onDecline) {
                    Text("Not Now")
                        .font(.caption)
                        .foregroundColor(.briefSecondaryText)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 20)
        #if os(macOS)
        .frame(width: 320, height: 400)
        #endif
    }

    private func disclosureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.briefPrimary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.briefSecondaryText)
            }
        }
    }
}

#if os(macOS)
extension Color {
    static func secondarySystemBackground() -> Color {
        return Color(NSColor.windowBackgroundColor)
    }
}

extension NSColor {
    static var secondarySystemBackground: NSColor {
        return NSColor.windowBackgroundColor
    }
}
#endif
