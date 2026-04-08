import SwiftUI

struct OnboardingView: View {
    @Binding var isCompleted: Bool
    @State private var page: Int = 0
    
    private let items: [OnboardingItem] = [
        OnboardingItem(
            title: "Track Every Match",
            subtitle: "Add upcoming fixtures and final scores in seconds.",
            systemImage: "calendar.badge.clock"
        ),
        OnboardingItem(
            title: "Build Team History",
            subtitle: "See results, form, and head-to-head stats in one place.",
            systemImage: "chart.line.uptrend.xyaxis"
        ),
        OnboardingItem(
            title: "Analyze Performance",
            subtitle: "Review goals, assists, tags, and match details quickly.",
            systemImage: "sportscourt.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.footBackground, Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        isCompleted = true
                    }
                    .foregroundColor(.gray)
                    .padding()
                }
                
                TabView(selection: $page) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        VStack(spacing: 24) {
                            Image(systemName: item.systemImage)
                                .font(.system(size: 76, weight: .semibold))
                                .foregroundColor(.footSuccess)
                                .footGlow()
                            
                            Text(item.title)
                                .font(.title.bold())
                                .foregroundColor(.white)
                            
                            Text(item.subtitle)
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                Button(action: nextAction) {
                    Text(page == items.count - 1 ? "Get started" : "Next")
                        .font(.headline)
                        .foregroundColor(.footBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.footSuccess)
                        .cornerRadius(14)
                        .footGlow()
                }
                .padding(.horizontal)
                .padding(.bottom, 28)
            }
        }
    }
    
    private func nextAction() {
        if page < items.count - 1 {
            withAnimation(.easeInOut) {
                page += 1
            }
        } else {
            isCompleted = true
        }
    }
}

private struct OnboardingItem {
    let title: String
    let subtitle: String
    let systemImage: String
}

