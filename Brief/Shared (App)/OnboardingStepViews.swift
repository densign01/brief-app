import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Email Step
struct EmailStepView: View {
    @Binding var email: String
    let onContinue: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Icon
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(
                        colors: [.briefPrimary, .briefSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                    .shadow(color: .briefPrimary.opacity(0.3), radius: 15, x: 0, y: 10)
                
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }
            .scaleEffect(isAnimating ? 1 : 0.8)
            .opacity(isAnimating ? 1 : 0)
            
            VStack(spacing: 12) {
                Text("Welcome to Brief")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("AI-powered link summaries\ndelivered straight to your inbox")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .offset(y: isAnimating ? 0 : 20)
            .opacity(isAnimating ? 1 : 0)
            
            VStack(spacing: 16) {
                TextField("your@email.com", text: $email)
                    #if os(iOS)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    #endif
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(Color.white)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(email.isValidEmail ? Color.briefPrimary.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Button(action: onContinue) {
                    HStack {
                        Text("Continue")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: email.isValidEmail ? [.briefPrimary, .briefSecondary] : [.gray.opacity(0.4), .gray.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .disabled(!email.isValidEmail)
            }
            .padding(.horizontal, 30)
            .offset(y: isAnimating ? 0 : 20)
            .opacity(isAnimating ? 1 : 0)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Enable Extension Step
struct EnableExtensionStepView: View {
    let onContinue: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Enable Brief")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Sharing via Brief requires a one-time setup of the Safari Extension.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                
                Link(destination: URL(string: "https://densign01.github.io/quickcapture/setup.html")!) {
                    HStack {
                        Image(systemName: "safari")
                        Text("Open Setup Guide in Safari")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.briefPrimary.opacity(0.1))
                    .foregroundColor(.briefPrimary)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.briefPrimary.opacity(0.2), lineWidth: 1)
                    )
                }
                
                Text("Or follow manually:")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .padding(.top, 10)

                VStack(alignment: .leading, spacing: 12) {
                    #if os(iOS)
                    instructionRow(number: "1", text: "Tap Share button in Safari", icon: "square.and.arrow.up")
                    instructionRow(number: "2", text: "Scroll to find 'Brief'", icon: "ellipsis.circle")
                    instructionRow(number: "3", text: "Toggle it on to enable", icon: "checkmark.circle.fill")
                    #else
                    instructionRow(number: "1", text: "Click Share in Safari", icon: "safari")
                    instructionRow(number: "2", text: "Select 'More...'", icon: "ellipsis")
                    instructionRow(number: "3", text: "Check 'Brief' to enable", icon: "checkmark.circle.fill")
                    #endif
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 30)
            .scaleEffect(isAnimating ? 1 : 0.9)
            .opacity(isAnimating ? 1 : 0)
            
            Button(action: onContinue) {
                HStack {
                    Text("Continue")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.briefPrimary, .briefSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(14)
            }
            .padding(.horizontal, 30)
            .offset(y: isAnimating ? 0 : 20)
            .opacity(isAnimating ? 1 : 0)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
    
    private func instructionRow(number: String, text: String, icon: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.briefPrimary.opacity(0.1))
                    .frame(width: 32, height: 32)
                Text(number)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.briefPrimary)
            }
            
            Image(systemName: icon)
                .foregroundColor(.briefSecondary)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - Share Demo Step
struct ShareDemoStepView: View {
    let onComplete: () -> Void
    
    enum DemoState: Int, CaseIterable {
        case browsing
        case tapping
        case selecting
        case sending
        case delivered
        
        var title: String {
            switch self {
            case .browsing: return "Find a link"
            case .tapping: return "Tap Share"
            case .selecting: return "Select Brief"
            case .sending: return "AI Summarizing..."
            case .delivered: return "Check your Email!"
            }
        }
    }
    
    @State private var demoState: DemoState = .browsing
    @State private var timer: Timer?
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 8) {
                Text("How it works")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Text(demoState.title)
                    .font(.headline)
                    .foregroundColor(.briefPrimary)
                    .id(demoState)
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
            }
            
            // Demo Container
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 10)
                
                VStack(spacing: 0) {
                    demoView
                        .transition(.opacity) // Use only opacity for smoother state switches
                }
            }
            .frame(height: 380) // Increased height to accommodate the full Safari mock without resizing
            .padding(.horizontal, 20)
            .scaleEffect(isAnimating ? 1 : 0.98)
            .opacity(isAnimating ? 1 : 0)
            
            Button(action: onComplete) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.briefPrimary, .briefSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 30)
            .offset(y: isAnimating ? 0 : 20)
            .opacity(isAnimating ? 1 : 0)
            
            Spacer()
        }
        .onAppear {
            startDemo()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    @ViewBuilder
    private var demoView: some View {
        ZStack {
            #if os(iOS)
            mockSafariWindow
            #else
            mockSafariWindow
            #endif
            
            if demoState == .tapping || demoState == .selecting {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                mockShareSheet(highlighted: demoState == .selecting)
                    .transition(.move(edge: .bottom))
            }
            
            if demoState == .sending || demoState == .delivered {
                Color.white.opacity(0.9)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                mockSuccessView(loading: demoState == .sending)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Realistic Mock UI Components
    
    private var mockSafariWindow: some View {
        VStack(spacing: 0) {
            // Safari Header / Address Bar
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "text.justify")
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 30)
                        .overlay(
                            HStack {
                                Image(systemName: "lock.fill").font(.system(size: 10))
                                Text("nytimes.com").font(.system(size: 12))
                                Spacer()
                                Image(systemName: "arrow.clockwise").font(.system(size: 10))
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                        )
                    Image(systemName: "plus")
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                Divider()
            }
            .background(Color(white: 0.98))
            
            // Article Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("The Future of AI")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                    
                    Text("JANUARY 1, 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "photo.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .clipped()
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(0..<4) { _ in
                            RoundedRectangle(cornerRadius: 2).fill(Color.gray.opacity(0.2)).frame(height: 8)
                        }
                        RoundedRectangle(cornerRadius: 2).fill(Color.gray.opacity(0.2)).frame(width: 150, height: 8)
                    }
                }
                .padding(20)
            }
            .disabled(true)
            
            // Safari Bottom Bar
            Divider()
            HStack {
                Image(systemName: "chevron.left")
                Spacer()
                Image(systemName: "chevron.right")
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.blue)
                    .scaleEffect(demoState == .tapping ? 1.5 : 1.0)
                    .overlay(
                        Circle().stroke(Color.blue, lineWidth: 2)
                            .scaleEffect(isAnimating ? 2 : 1)
                            .opacity(isAnimating ? 0 : 1)
                            .opacity(demoState == .tapping ? 1 : 0)
                    )
                Spacer()
                Image(systemName: "book")
                Spacer()
                Image(systemName: "square.on.square")
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(white: 0.98))
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Locked size
    }
    
    private func mockShareSheet(highlighted: Bool) -> some View {
        VStack(spacing: 20) {
            Capsule().fill(Color.gray.opacity(0.3)).frame(width: 40, height: 5)
            
            VStack(alignment: .leading, spacing: 15) {
                // Apps Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        shareAppIcon(name: "Brief", icon: "doc.text.fill", color: .briefPrimary, highlighted: highlighted)
                        shareAppIcon(name: "Messages", icon: "message.fill", color: .green, highlighted: false)
                        shareAppIcon(name: "Mail", icon: "envelope.fill", color: .blue, highlighted: false)
                        shareAppIcon(name: "Notes", icon: "note.text", color: .yellow, highlighted: false)
                        shareAppIcon(name: "X", icon: "twitter", color: .black, highlighted: false)
                    }
                    .padding(.horizontal, 20)
                }
                
                Divider().padding(.horizontal, 20)
                
                // Actions List
                VStack(spacing: 0) {
                    shareActionRow(name: "Copy", icon: "doc.on.doc")
                    shareActionRow(name: "Add to Reading List", icon: "book")
                    shareActionRow(name: "Add Bookmark", icon: "bookmark")
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 30)
        }
        .padding(.top, 10)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(white: 0.95)))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .frame(maxHeight: 280)
        .frame(maxWidth: .infinity, alignment: .bottom)
    }
    
    private func shareAppIcon(name: String, icon: String, color: Color, highlighted: Bool) -> some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(width: 54, height: 54)
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.title3)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 3)
                    .padding(-4)
                    .opacity(highlighted ? 1 : 0)
            )
            .scaleEffect(highlighted && isAnimating ? 1.05 : 1.0)
            
            Text(name)
                .font(.system(size: 11))
                .foregroundColor(.primary)
        }
    }
    
    private func shareActionRow(name: String, icon: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .font(.system(size: 16))
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 12)
            Divider()
        }
    }
    
    private func mockSuccessView(loading: Bool) -> some View {
        VStack(spacing: 24) {
            if loading {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.briefPrimary.opacity(0.1), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(Color.briefPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                            .onAppear {
                                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                    isAnimating = true
                                }
                            }
                    }
                    
                    Text("Analyzing...")
                        .font(.headline)
                        .foregroundColor(.briefPrimary)
                }
            } else {
                VStack(spacing: 20) {
                    ZStack {
                        Circle().fill(Color.green).frame(width: 80, height: 80)
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Summary Sent!")
                            .font(.title2.bold())
                        Text("Check your inbox for the key takeaways.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(40)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Locked size
    }

    private func startDemo() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation {
                let nextIndex = (demoState.rawValue + 1) % DemoState.allCases.count
                demoState = DemoState(rawValue: nextIndex) ?? .browsing
            }
        }
    }
}

// MARK: - Helpers

#if os(iOS)
typealias PlatformCorner = UIRectCorner
#else
struct PlatformCorner: OptionSet {
    let rawValue: Int
    static let topLeft = PlatformCorner(rawValue: 1 << 0)
    static let topRight = PlatformCorner(rawValue: 1 << 1)
    static let bottomLeft = PlatformCorner(rawValue: 1 << 2)
    static let bottomRight = PlatformCorner(rawValue: 1 << 3)
    static let allCorners: PlatformCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}
#endif

extension View {
    func cornerRadius(_ radius: CGFloat, corners: PlatformCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: PlatformCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        #if os(iOS)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
        #else
        // Simplified macOS version (AppKit doesn't have a direct equivalent to byRoundingCorners in NSBezierPath)
        return Path(rect) // Fallback or implement custom path
        #endif
    }
}

extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}
