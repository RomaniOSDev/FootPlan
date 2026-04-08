import SwiftUI

struct PlayersStatsView: View {
    @ObservedObject var viewModel: FootPlanViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Players stats")
                            .font(.largeTitle.bold())
                            .foregroundColor(.footSuccess)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    advancedStatsSection
                    scorersSection
                    assistersSection
                }
                .padding(.bottom, 24)
            }
            .background(Color.footBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
    
    private var advancedStatsSection: some View {
        VStack(spacing: 12) {
            HStack {
                StatCard(
                    title: "Win rate",
                    value: String(format: "%.0f%%", viewModel.winRate * 100),
                    icon: "percent",
                    color: .footSuccess,
                    cardColor: .footCard
                )
                
                StatCard(
                    title: "Avg goals for",
                    value: String(format: "%.2f", viewModel.averageGoalsFor),
                    icon: "soccerball",
                    color: .footSuccess,
                    cardColor: .footCard
                )
            }
            
            HStack {
                StatCard(
                    title: "Avg goals against",
                    value: String(format: "%.2f", viewModel.averageGoalsAgainst),
                    icon: "shield.lefthalf.filled",
                    color: .footSuccess,
                    cardColor: .footCard
                )
                
                StatCard(
                    title: "Clean sheets",
                    value: "\(viewModel.cleanSheetsCount)",
                    icon: "lock.fill",
                    color: .footSuccess,
                    cardColor: .footCard
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var scorersSection: some View {
        VStack(alignment: .leading) {
            Text("Top scorers")
                .font(.headline)
                .foregroundColor(.footSuccess)
                .padding(.horizontal)
            
            ForEach(Array(viewModel.topScorers.enumerated()), id: \.element.id) { index, scorer in
                HStack {
                    Text("\(index + 1)")
                        .foregroundColor(.footSuccess)
                        .frame(width: 30)
                    
                    Text(scorer.playerName)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(scorer.goals)")
                        .foregroundColor(.footSuccess)
                        .font(.title3)
                        .bold()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(index % 2 == 0 ? Color.footCard : Color.clear)
            }
        }
        .padding(.vertical)
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 12)
        .padding(.horizontal)
    }
    
    private var assistersSection: some View {
        VStack(alignment: .leading) {
            Text("Top assisters")
                .font(.headline)
                .foregroundColor(.footSuccess)
                .padding(.horizontal)
            
            ForEach(Array(viewModel.topAssisters.enumerated()), id: \.element.id) { index, assister in
                HStack {
                    Text("\(index + 1)")
                        .foregroundColor(.footSuccess)
                        .frame(width: 30)
                    
                    Text(assister.playerName)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(assister.assists)")
                        .foregroundColor(.footSuccess)
                        .font(.title3)
                        .bold()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(index % 2 == 0 ? Color.footCard : Color.clear)
            }
        }
        .padding(.vertical)
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 12)
        .padding(.horizontal)
    }
}

