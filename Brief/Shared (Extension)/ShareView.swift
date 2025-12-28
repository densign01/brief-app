import SwiftUI

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
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let appGroup = "group.com.quickcapture.brief"

    init(url: String, pageTitle: String, onSend: @escaping (String?, Bool, String) -> Void, onCancel: @escaping () -> Void) {
        self.url = url
        self.pageTitle = pageTitle
        self.onSend = onSend
        self.onCancel = onCancel

        // Load preferences from app group
        let defaults = UserDefaults(suiteName: "group.com.quickcapture.brief")
        _aiSummaryEnabled = State(initialValue: defaults?.bool(forKey: "aiSummaryEnabled") ?? true)
        _summaryLength = State(initialValue: defaults?.string(forKey: "summaryLength") ?? "short")
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Brief")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    onCancel()
                }
                #if os(iOS)
                .foregroundColor(.blue)
                #endif
            }
            .padding(.bottom, 8)

            // Article info
            VStack(alignment: .leading, spacing: 8) {
                Text(pageTitle.isEmpty ? "Shared Link" : pageTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                Text(url)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)

            // Context/note input
            VStack(alignment: .leading, spacing: 4) {
                Text("Note (optional)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                #if os(iOS)
                TextField("Add a personal note...", text: $context, axis: .vertical)
                    .lineLimit(2...4)
                    .textFieldStyle(.roundedBorder)
                #else
                TextEditor(text: $context)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                #endif
            }

            // AI Summary toggle
            VStack(alignment: .leading, spacing: 8) {
                Toggle("AI Summary", isOn: $aiSummaryEnabled)
                    .onChange(of: aiSummaryEnabled) { _, newValue in
                        savePreference(key: "aiSummaryEnabled", value: newValue)
                    }

                if aiSummaryEnabled {
                    Picker("Length", selection: $summaryLength) {
                        Text("Short").tag("short")
                        Text("Long").tag("long")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: summaryLength) { _, newValue in
                        savePreference(key: "summaryLength", value: newValue)
                    }
                }
            }

            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
            }

            Spacer()

            // Send button
            Button(action: {
                isLoading = true
                errorMessage = nil
                onSend(
                    context.isEmpty ? nil : context,
                    aiSummaryEnabled,
                    summaryLength
                )
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            #if os(iOS)
                            .tint(.white)
                            #endif
                    }
                    Text(isLoading ? "Sending..." : "Send to Email")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding(20)
        #if os(iOS)
        .background(Color(.systemBackground))
        #endif
    }

    private func savePreference(key: String, value: Any) {
        UserDefaults(suiteName: appGroup)?.set(value, forKey: key)
    }

    func showError(_ message: String) {
        isLoading = false
        errorMessage = message
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
