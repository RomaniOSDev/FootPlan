import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: FootPlanViewModel
    @State private var showingAddMatch = false
    
    private var nextMatch: Match? {
        viewModel.matches
            .filter { $0.result == .notPlayed }
            .sorted { $0.date < $1.date }
            .first
    }
    
    private var lastMatch: Match? {
        viewModel.matches
            .filter { $0.result != .notPlayed }
            .sorted { $0.date > $1.date }
            .first
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.footBackground, Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        mainStatsRow
                        if let nextMatch {
                            nextMatchCard(nextMatch)
                        }
                        if let lastMatch {
                            lastResultCard(lastMatch)
                        }
                        quickActions
                    }
                    .padding(.bottom, 24)
                }
            }
            .sheet(isPresented: $showingAddMatch) {
                AddMatchView(viewModel: viewModel)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Foot plan")
                .font(.largeTitle.bold())
                .foregroundColor(.footSuccess)
                .footGlow()
            
            if let team = viewModel.favoriteTeam {
                HStack(spacing: 8) {
                    Text(team.logo ?? "⚽️")
                        .font(.title2)
                    Text(team.name)
                        .foregroundColor(.white)
                        .font(.headline)
                    if let city = team.city {
                        Text("· \(city)")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                }
            } else {
                Text("Set your favorite team to personalise stats.")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var mainStatsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                StatCard(
                    title: "Matches",
                    value: "\(viewModel.totalMatches)",
                    icon: "sportscourt.fill",
                    color: .footSuccess,
                    cardColor: .footCard
                )
                
                StatCard(
                    title: "Win rate",
                    value: viewModel.totalMatches > 0 ? String(format: "%.0f%%", viewModel.winRate * 100) : "–",
                    icon: "percent",
                    color: .footSuccess,
                    cardColor: .footCard
                )
                
                StatCard(
                    title: "Goals",
                    value: "\(viewModel.totalGoals)",
                    icon: "soccerball",
                    color: .footSuccess,
                    cardColor: .footCard
                )
                
                StatCard(
                    title: "Form",
                    value: viewModel.recentForm.isEmpty ? "—" : viewModel.recentForm,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .footSuccess,
                    cardColor: .footCard
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func nextMatchCard(_ match: Match) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Next match")
                    .font(.headline)
                    .foregroundColor(.footSuccess)
                Spacer()
                Text(formattedDate(match.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                VStack(alignment: .trailing) {
                    Text("OUR")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 80)
                
                Text("VS")
                    .font(.headline)
                    .foregroundColor(.footSuccess)
                
                VStack(alignment: .leading) {
                    Text(match.opponent.shortName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(match.competition.englishName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: match.venue.icon)
                        .foregroundColor(.footSuccess)
                        .font(.caption)
                    Text(match.venue.englishName)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 16)
        .padding(.horizontal)
    }
    
    private func lastResultCard(_ match: Match) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Last result")
                    .font(.headline)
                    .foregroundColor(.footSuccess)
                Spacer()
                Text(formattedShortDate(match.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                VStack(alignment: .trailing) {
                    Text("OUR")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("\(match.ourScore ?? 0)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(match.result == .win ? .footSuccess : .white)
                }
                .frame(width: 70)
                
                Text(":")
                    .font(.title2.bold())
                    .foregroundColor(.footSuccess)
                
                VStack(alignment: .leading) {
                    Text(match.opponent.shortName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(match.opponentScore ?? 0)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(match.result == .loss ? .footSuccess.opacity(0.7) : .white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: match.result.icon)
                        Text(match.result.title)
                    }
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(match.result.color.opacity(0.2))
                    .foregroundColor(match.result.color)
                    .cornerRadius(12)
                    
                    if !match.tags.isEmpty {
                        Text(match.tags.joined(separator: ", "))
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding()
        .background(Color.footCard)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.footSuccess.opacity(0.35), lineWidth: 1)
        )
        .footCardStyle(cornerRadius: 16)
        .padding(.horizontal)
    }
    
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick actions")
                .font(.headline)
                .foregroundColor(.footSuccess)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                NavigationLink(destination: ScheduleView(viewModel: viewModel)) {
                    quickActionButton(
                        title: "Schedule",
                        subtitle: "All fixtures & results",
                        icon: "calendar"
                    )
                }
                
                Button {
                    showingAddMatch = true
                } label: {
                    quickActionButton(
                        title: "New match",
                        subtitle: "Add result or fixture",
                        icon: "plus.circle"
                    )
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                NavigationLink(destination: PlayersStatsView(viewModel: viewModel)) {
                    quickActionButton(
                        title: "Players",
                        subtitle: "Goals & assists",
                        icon: "person.3.fill"
                    )
                }
                
                NavigationLink(destination: HeadToHeadView(viewModel: viewModel)) {
                    quickActionButton(
                        title: "Opponents",
                        subtitle: "Head-to-head stats",
                        icon: "chart.bar.fill"
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
    
    private func quickActionButton(title: String, subtitle: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.footSuccess)
                Spacer()
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 14)
    }
}

