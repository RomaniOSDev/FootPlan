import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @ObservedObject var viewModel: FootPlanViewModel
    @State private var showClearDataAlert = false
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.footBackground.ignoresSafeArea()
                
                VStack(spacing: 14) {
                    settingsButton(
                        title: "Rate us",
                        icon: "star.bubble.fill",
                        action: rateApp
                    )
                    
                    settingsButton(
                        title: "Privacy Policy",
                        icon: "lock.doc.fill",
                        action: openPrivacyPolicy
                    )
                    
                    settingsButton(
                        title: "Terms of Use",
                        icon: "doc.text.fill",
                        action: openTerms
                    )
                    
                    settingsButton(
                        title: "Reset onboarding",
                        icon: "arrow.counterclockwise.circle.fill",
                        action: resetOnboarding
                    )
                    
                    settingsButton(
                        title: "Clear all app data",
                        icon: "trash.fill",
                        action: { showClearDataAlert = true }
                    )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("App info")
                            .font(.headline)
                            .foregroundColor(.footSuccess)
                        Text("Version \(appVersion) (\(buildNumber))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.footCard)
                    .footCardStyle(cornerRadius: 12)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Clear all app data?", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will remove matches, teams, and players from this device.")
        }
    }
    
    private func settingsButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.footSuccess)
                    .font(.headline)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.white)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
            .background(Color.footCard)
            .footCardStyle(cornerRadius: 12)
        }
        .buttonStyle(.plain)
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: AppLinks.privacyPolicy.rawValue) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTerms() {
        if let url = URL(string: AppLinks.termsOfUse.rawValue) {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "onboarding_completed")
    }
    
    private func clearAllData() {
        viewModel.clearAllData()
        UserDefaults.standard.set(false, forKey: "onboarding_completed")
    }
}

