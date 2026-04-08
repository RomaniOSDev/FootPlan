import SwiftUI

struct MatchDetailView: View {
    let match: Match
    @ObservedObject var viewModel: FootPlanViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    
                    if !match.goalscorers.isEmpty {
                        goalsSection
                    }
                    
                    if !match.assists.isEmpty {
                        assistsSection
                    }
                    
                    if let notes = match.notes, !notes.isEmpty {
                        notesSection(notes: notes)
                    }
                    
                    if !match.tags.isEmpty {
                        tagsSection
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.footBackground.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.footSuccess)
                }
            }
            .safeAreaInset(edge: .bottom) {
                actionButtons
                    .background(Color.footBackground)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .confirmationDialog(
            "Delete match?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteMatch(match)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: match.competition.icon)
                    .foregroundColor(.footSuccess)
                
                Text(match.competition.englishName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(formattedDate(match.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                VStack {
                    Text("OUR")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(match.ourScore != nil ? "\(match.ourScore!)" : "?")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(match.result == .win ? .footSuccess : .white)
                }
                .frame(maxWidth: .infinity)
                
                Text(":")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.footSuccess)
                
                VStack {
                    Text(match.opponent.shortName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(match.opponentScore != nil ? "\(match.opponentScore!)" : "?")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(match.result == .loss ? .footSuccess.opacity(0.7) : .white)
                }
                .frame(maxWidth: .infinity)
            }
            
            if match.result != .notPlayed {
                HStack {
                    Image(systemName: match.result.icon)
                    Text(match.result.title)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(match.result.color.opacity(0.2))
                .foregroundColor(match.result.color)
                .cornerRadius(20)
            }
            
            HStack {
                Image(systemName: match.venue.icon)
                    .foregroundColor(.footSuccess)
                Text(match.venue.englishName)
                    .foregroundColor(.gray)
            }
            .font(.caption)
        }
        .padding()
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading) {
            Text("Goals")
                .font(.headline)
                .foregroundColor(.footSuccess)
            
            ForEach(match.goalscorers) { scorer in
                HStack {
                    Image(systemName: "soccerball")
                        .foregroundColor(.footSuccess)
                        .frame(width: 24)
                    
                    Text(scorer.playerName)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(scorer.minute)'")
                        .foregroundColor(.footSuccess)
                        .font(.caption)
                    
                    if scorer.isPenalty {
                        Text("(pen.)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    if scorer.isOwnGoal {
                        Text("(o.g.)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 12)
        .padding(.horizontal)
    }
    
    private var assistsSection: some View {
        VStack(alignment: .leading) {
            Text("Assists")
                .font(.headline)
                .foregroundColor(.footSuccess)
            
            ForEach(match.assists) { assist in
                HStack {
                    Image(systemName: "shoe")
                        .foregroundColor(.footSuccess)
                        .frame(width: 24)
                    
                    Text(assist.playerName)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(assist.minute)'")
                        .foregroundColor(.footSuccess)
                        .font(.caption)
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 12)
        .padding(.horizontal)
    }
    
    private func notesSection(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
                .foregroundColor(.footSuccess)
            
            Text(notes)
                .foregroundColor(.white)
                .font(.body)
        }
        .padding()
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 12)
        .padding(.horizontal)
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(.footSuccess)
            
            WrapTagsView(tags: match.tags)
        }
        .padding()
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 12)
        .padding(.horizontal)
    }
    
    private var actionButtons: some View {
        HStack {
            Button("Edit") {
                showEditSheet = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.footSuccess)
            .foregroundColor(.footBackground)
            .cornerRadius(10)
            .footGlow()
            
            Button("Delete") {
                showDeleteConfirmation = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.footSuccess, lineWidth: 1)
            )
            .foregroundColor(.footSuccess)
        }
        .padding()
        .sheet(isPresented: $showEditSheet) {
            // For simplicity, reuse AddMatchView later if needed
            AddMatchView(viewModel: viewModel)
        }
    }
}

