import SwiftUI

struct AddMatchView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: FootPlanViewModel
    
    @State private var date: Date = Date()
    @State private var competition: Competition = .league
    @State private var venue: Venue = .home
    
    @State private var selectedOpponentId: UUID?
    @State private var newOpponentName: String = ""
    @State private var newOpponentShortName: String = ""
    
    @State private var ourScore: Int?
    @State private var opponentScore: Int?
    
    @State private var goalscorers: [GoalScorer] = []
    @State private var assists: [Assist] = []
    @State private var notes: String = ""
    @State private var isFavorite: Bool = false
    @State private var selectedTags: Set<String> = []
    
    private let availableTags = ["Derby", "Clean sheet", "Rotated squad", "Injury", "Big win"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.footBackground
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        DatePicker("Date & time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                            .accentColor(.footSuccess)
                        
                        Picker("Competition", selection: $competition) {
                            ForEach(Competition.allCases, id: \.self) { comp in
                                Label(comp.englishName, systemImage: comp.icon).tag(comp)
                            }
                        }
                        .accentColor(.footSuccess)
                        
                        Picker("Venue", selection: $venue) {
                            ForEach(Venue.allCases, id: \.self) { venue in
                                Label(venue.englishName, systemImage: venue.icon).tag(venue)
                            }
                        }
                        .accentColor(.footSuccess)
                    }
                    .listRowBackground(Color.footCard)
                    
                    Section(header: Text("Opponent").foregroundColor(.gray)) {
                        Picker("Team", selection: $selectedOpponentId) {
                            ForEach(viewModel.teams) { team in
                                Text(team.name).tag(team.id as UUID?)
                            }
                            Text("➕ New team").tag(nil as UUID?)
                        }
                        .accentColor(.footSuccess)
                        
                        if selectedOpponentId == nil {
                            TextField("Team name", text: $newOpponentName)
                                .foregroundColor(.white)
                                .accentColor(.footSuccess)
                            
                            TextField("Short name", text: $newOpponentShortName)
                                .foregroundColor(.white)
                                .accentColor(.footSuccess)
                        }
                    }
                    .listRowBackground(Color.footCard)
                    
                    Section(header: Text("Score").foregroundColor(.gray)) {
                        HStack {
                            Text("Our team")
                            Spacer()
                            TextField("0", value: $ourScore, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 60)
                                .multilineTextAlignment(.center)
                        }
                        
                        HStack {
                            Text("Opponent")
                            Spacer()
                            TextField("0", value: $opponentScore, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 60)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .listRowBackground(Color.footCard)
                    
                    Section(header: Text("Goals").foregroundColor(.gray)) {
                        ForEach(goalscorers.indices, id: \.self) { index in
                            HStack {
                                TextField("Player", text: $goalscorers[index].playerName)
                                    .foregroundColor(.white)
                                
                                TextField("min", value: $goalscorers[index].minute, format: .number)
                                    .frame(width: 60)
                                    .keyboardType(.numberPad)
                                
                                Button {
                                    goalscorers.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                            }
                            .accentColor(.footSuccess)
                        }
                        
                        Button("Add goal") {
                            goalscorers.append(GoalScorer(id: UUID(), playerName: "", minute: 0, isPenalty: false, isOwnGoal: false))
                        }
                        .foregroundColor(.footSuccess)
                    }
                    .listRowBackground(Color.footCard)
                    
                    Section(header: Text("Assists").foregroundColor(.gray)) {
                        ForEach(assists.indices, id: \.self) { index in
                            HStack {
                                TextField("Player", text: $assists[index].playerName)
                                    .foregroundColor(.white)
                                
                                TextField("min", value: $assists[index].minute, format: .number)
                                    .frame(width: 60)
                                    .keyboardType(.numberPad)
                                
                                Button {
                                    assists.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                            }
                            .accentColor(.footSuccess)
                        }
                        
                        Button("Add assist") {
                            assists.append(Assist(id: UUID(), playerName: "", minute: 0))
                        }
                        .foregroundColor(.footSuccess)
                    }
                    .listRowBackground(Color.footCard)
                    
                    Section(header: Text("Notes").foregroundColor(.gray)) {
                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .foregroundColor(.white)
                            .accentColor(.footSuccess)
                    }
                    .listRowBackground(Color.footCard)
                    
                    Section(header: Text("Tags").foregroundColor(.gray)) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(availableTags, id: \.self) { tag in
                                    let isOn = selectedTags.contains(tag)
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(isOn ? Color.footSuccess : Color.footCard)
                                        .foregroundColor(isOn ? .footBackground : .white)
                                        .cornerRadius(12)
                                        .onTapGesture {
                                            if isOn {
                                                selectedTags.remove(tag)
                                            } else {
                                                selectedTags.insert(tag)
                                            }
                                        }
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.footCard)
                    
                    Section {
                        Toggle("Favorite", isOn: $isFavorite)
                            .tint(.footSuccess)
                    }
                    .listRowBackground(Color.footCard)
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
                .environment(\.colorScheme, .dark)
            }
            .navigationTitle("New match")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.footSuccess)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMatch()
                    }
                    .foregroundColor(.footBackground)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.footSuccess)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func resolveOpponent() -> Team? {
        if let id = selectedOpponentId,
           let team = viewModel.teams.first(where: { $0.id == id }) {
            return team
        }
        
        guard !newOpponentName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }
        
        let short = newOpponentShortName.isEmpty ? newOpponentName : newOpponentShortName
        let team = Team(
            id: UUID(),
            name: newOpponentName,
            shortName: short,
            logo: nil,
            city: nil,
            stadium: nil,
            isFavorite: false
        )
        viewModel.addTeam(team)
        return team
    }
    
    private func saveMatch() {
        guard let opponent = resolveOpponent() else { return }
        
        let match = Match(
            id: UUID(),
            date: date,
            competition: competition,
            opponent: opponent,
            venue: venue,
            ourScore: ourScore,
            opponentScore: opponentScore,
            goalscorers: goalscorers,
            assists: assists,
            lineup: nil,
            substitutions: nil,
            yellowCards: nil,
            redCards: nil,
            notes: notes.isEmpty ? nil : notes,
            tags: Array(selectedTags),
            isFavorite: isFavorite,
            createdAt: Date()
        )
        
        viewModel.addMatch(match)
        dismiss()
    }
}

