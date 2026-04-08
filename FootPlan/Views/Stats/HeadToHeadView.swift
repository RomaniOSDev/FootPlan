import SwiftUI

struct HeadToHeadView: View {
    @ObservedObject var viewModel: FootPlanViewModel
    
    @State private var selectedOpponent: String?
    @State private var sortOption: SortOption = .byWins
    
    enum SortOption {
        case byWins
        case byGoalDifference
        case byWinRate
    }
    
    private var sortedHeadToHead: [HeadToHead] {
        switch sortOption {
        case .byWins:
            return viewModel.headToHead.sorted { $0.wins > $1.wins }
        case .byGoalDifference:
            return viewModel.headToHead.sorted {
                ($0.goalsFor - $0.goalsAgainst) > ($1.goalsFor - $1.goalsAgainst)
            }
        case .byWinRate:
            return viewModel.headToHead.sorted {
                let r0 = $0.totalMatches > 0 ? Double($0.wins) / Double($0.totalMatches) : 0
                let r1 = $1.totalMatches > 0 ? Double($1.wins) / Double($1.totalMatches) : 0
                return r0 > r1
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.footBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Head-to-head")
                            .font(.largeTitle.bold())
                            .foregroundColor(.footSuccess)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        Picker("", selection: $sortOption) {
                            Text("Wins").tag(SortOption.byWins)
                            Text("GD").tag(SortOption.byGoalDifference)
                            Text("Win rate").tag(SortOption.byWinRate)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(sortedHeadToHead) { h2h in
                                H2HCard(h2h: h2h)
                                    .onTapGesture {
                                        selectedOpponent = h2h.opponentName
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

private struct H2HCard: View {
    let h2h: HeadToHead
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(h2h.opponentName)
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                VStack {
                    Text("Wins")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("\(h2h.wins)")
                        .font(.title2)
                        .foregroundColor(.footSuccess)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("Draws")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("\(h2h.draws)")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("Losses")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("\(h2h.losses)")
                        .font(.title2)
                        .foregroundColor(.footSuccess.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
            }
            
            HStack {
                Text("Goals:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("\(h2h.goalsFor)")
                    .foregroundColor(.footSuccess)
                
                Text(":")
                    .foregroundColor(.gray)
                
                Text("\(h2h.goalsAgainst)")
                    .foregroundColor(.footSuccess.opacity(0.7))
                
                Spacer()
                
                Text("Total: \(h2h.totalMatches) matches")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 12)
    }
}

