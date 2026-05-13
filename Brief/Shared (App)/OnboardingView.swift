import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @State private var currentStep = 0
    @State private var email = ""
    
    var body: some View {
        ZStack {
            Color.briefBackground.ignoresSafeArea()
            
            #if os(iOS)
            VStack {
                TabView(selection: $currentStep) {
                    EmailStepView(email: $email, onContinue: {
                        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
                        userPreferences.email = email
                        withAnimation { currentStep = 1 }
                    })
                    .tag(0)
                    
                    EnableExtensionStepView(onContinue: {
                        withAnimation { currentStep = 2 }
                    })
                    .tag(1)
                    
                    ShareDemoStepView(onComplete: {
                        withAnimation {
                            userPreferences.hasCompletedOnboarding = true
                        }
                    })
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentStep == index ? Color.briefPrimary : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .onTapGesture {
                                withAnimation {
                                    if index == 0 || (index == 1 && !email.isEmpty) || index == 2 {
                                         currentStep = index
                                    }
                                }
                            }
                    }
                }
                .padding(.bottom, 20)
            }
            #else
            // macOS Version
            VStack {
                Group {
                    if currentStep == 0 {
                        EmailStepView(email: $email, onContinue: {
                            email = email.trimmingCharacters(in: .whitespacesAndNewlines)
                            userPreferences.email = email
                            withAnimation { currentStep = 1 }
                        })
                    } else if currentStep == 1 {
                        EnableExtensionStepView(onContinue: {
                            withAnimation { currentStep = 2 }
                        })
                    } else {
                        ShareDemoStepView(onComplete: {
                            userPreferences.hasCompletedOnboarding = true
                        })
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                
                if currentStep > 0 {
                    Button(action: { withAnimation { currentStep -= 1 } }) {
                        Text("Back")
                            .foregroundColor(.briefSecondaryText)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 20)
                }
            }
            .frame(width: 500, height: 600)
            #endif
        }
        .onOpenURL { url in
            // Handle deep link from setup guide: brief://setup-complete
            if url.absoluteString.contains("setup-complete") {
                withAnimation {
                    if currentStep == 1 {
                        currentStep = 2
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(UserPreferences.shared)
}
