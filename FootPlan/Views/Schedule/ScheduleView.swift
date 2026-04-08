import SwiftUI

struct ScheduleView: View {
    @ObservedObject var viewModel: FootPlanViewModel
    
    @State private var selectedFilter: FootPlanViewModel.Filter = .upcoming
    @State private var selectedMatch: Match?
    @State private var showingAddMatch = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                Color.footBackground
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Match schedule")
                            .font(.largeTitle.bold())
                            .foregroundColor(.footSuccess)
                        
                        Text("Season \(Calendar.current.component(.year, from: Date()))/\(Calendar.current.component(.year, from: Date()) + 1)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
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
                                title: "Wins",
                                value: "\(viewModel.winsCount)",
                                icon: "trophy.fill",
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
                                value: viewModel.recentForm,
                                icon: "chart.line.uptrend.xyaxis",
                                color: .footSuccess,
                                cardColor: .footCard
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Picker("", selection: $selectedFilter) {
                        Text("Upcoming").tag(FootPlanViewModel.Filter.upcoming)
                        Text("Played").tag(FootPlanViewModel.Filter.past)
                        Text("All").tag(FootPlanViewModel.Filter.all)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .accentColor(.footSuccess)
                    .onChange(of: selectedFilter) { newValue in
                        viewModel.selectedFilter = newValue
                    }
                    .onAppear {
                        selectedFilter = viewModel.selectedFilter
                    }
                    
                    HStack {
                        Menu {
                            Button("All competitions") { viewModel.competitionFilter = nil }
                            Divider()
                            ForEach(Competition.allCases, id: \.self) { comp in
                                Button(comp.englishName) {
                                    viewModel.competitionFilter = comp
                                }
                            }
                        } label: {
                            Label("Competition", systemImage: "trophy")
                                .foregroundColor(.footSuccess)
                        }
                        
                        Menu {
                            Button("All venues") { viewModel.venueFilter = nil }
                            Divider()
                            ForEach(Venue.allCases, id: \.self) { venue in
                                Button(venue.englishName) {
                                    viewModel.venueFilter = venue
                                }
                            }
                        } label: {
                            Label("Venue", systemImage: "house")
                                .foregroundColor(.footSuccess)
                        }
                        
                        Menu {
                            Button("By date") { viewModel.sortOption = .byDate }
                            Button("By opponent") { viewModel.sortOption = .byOpponent }
                            Button("Favorites first") { viewModel.sortOption = .favoritesFirst }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                                .foregroundColor(.footSuccess)
                        }
                    }
                    .font(.caption)
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredMatches) { match in
                                MatchCard(match: match)
                                    .onTapGesture {
                                        selectedMatch = match
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            viewModel.deleteMatch(match)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            viewModel.toggleFavoriteMatch(match)
                                        } label: {
                                            Label("Favorite", systemImage: "star")
                                        }
                                        .tint(.footSuccess)
                                    }
                            }
                        }
                        .padding()
                    }
                }
                
                Button {
                    showingAddMatch = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.footSuccess)
                        .footGlow()
                }
                .padding()
            }
            .sheet(isPresented: $showingAddMatch) {
                AddMatchView(viewModel: viewModel)
            }
            .sheet(item: $selectedMatch) { match in
                MatchDetailView(match: match, viewModel: viewModel)
            }
            .navigationBarHidden(true)
        }
    }
}

private struct MatchCard: View {
    let match: Match
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: match.competition.icon)
                    .foregroundColor(.footSuccess)
                    .font(.caption)
                
                Text(formattedDate(match.date))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if match.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.footSuccess)
                        .font(.caption)
                }
            }
            
            HStack {
                VStack(alignment: .trailing) {
                    Text("OUR")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(match.ourScore != nil ? "\(match.ourScore!)" : "?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(match.result == .win ? .footSuccess : .white)
                }
                .frame(width: 80)
                
                Text("VS")
                    .font(.headline)
                    .foregroundColor(.footSuccess)
                
                VStack(alignment: .leading) {
                    Text(match.opponent.shortName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(match.opponentScore != nil ? "\(match.opponentScore!)" : "?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(match.result == .loss ? .footSuccess.opacity(0.7) : .white)
                }
                .frame(width: 80)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Image(systemName: match.venue.icon)
                        .foregroundColor(.footSuccess)
                        .font(.caption)
                    
                    Text(match.venue.englishName)
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if match.result != .notPlayed {
                        Image(systemName: match.result.icon)
                            .foregroundColor(match.result.color)
                            .font(.caption)
                    }
                }
            }
            
            if match.result != .notPlayed {
                Text(match.result.title)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(match.result.color.opacity(0.2))
                    .foregroundColor(match.result.color)
                    .cornerRadius(8)
            }
            
            if !match.goalscorers.isEmpty {
                HStack {
                    Image(systemName: "soccerball")
                        .font(.caption)
                        .foregroundColor(.footSuccess)
                    
                    Text(match.goalscorers.map { "\($0.playerName) (\($0.minute)')" }.joined(separator: ", "))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .background(Color.footCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(match.result == .win ? Color.footSuccess.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .footCardStyle(cornerRadius: 12)
    }
}

