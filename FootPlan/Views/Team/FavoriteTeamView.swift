import SwiftUI

struct FavoriteTeamView: View {
    @ObservedObject var viewModel: FootPlanViewModel
    @State private var isEditing = false
    @State private var isAddingTeam = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.footBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Favorite team")
                            .font(.largeTitle.bold())
                            .foregroundColor(.footSuccess)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        if let team = viewModel.favoriteTeam {
                            teamCard(team: team)
                        } else {
                            Button {
                                isEditing = true
                            } label: {
                                HStack {
                                    Image(systemName: "star")
                                        .foregroundColor(.footSuccess)
                                    Text("Set favorite team")
                                        .foregroundColor(.footSuccess)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.footCard)
                                .footCardStyle(cornerRadius: 12)
                                .padding(.horizontal)
                            }
                        }
                        
                        HStack {
                            Text("Teams")
                                .font(.headline)
                                .foregroundColor(.footSuccess)
                            Spacer()
                            Button {
                                isAddingTeam = true
                            } label: {
                                Label("Add team", systemImage: "plus")
                                    .font(.caption)
                                    .foregroundColor(.footSuccess)
                            }
                        }
                        .padding(.horizontal)
                        
                        ForEach(viewModel.teams) { team in
                            teamListRow(team)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                FavoriteTeamEditView(viewModel: viewModel)
            }
            .sheet(isPresented: $isAddingTeam) {
                AddTeamView(viewModel: viewModel)
            }
            .navigationBarHidden(true)
        }
    }
    
    private func teamCard(team: Team) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(team.logo ?? "⚽️")
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    if let city = team.city {
                        Text(city)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button {
                    isEditing = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.footSuccess)
                }
            }
            
            if let stadium = team.stadium {
                HStack {
                    Image(systemName: "building.2")
                        .foregroundColor(.footSuccess)
                    Text(stadium)
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Matches")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(viewModel.totalMatches)")
                        .foregroundColor(.white)
                        .bold()
                }
                VStack(alignment: .leading) {
                    Text("Goals")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(viewModel.totalGoals)")
                        .foregroundColor(.footSuccess)
                        .bold()
                }
                VStack(alignment: .leading) {
                    Text("Win rate")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "%.0f%%", viewModel.winRate * 100))
                        .foregroundColor(.footSuccess)
                        .bold()
                }
            }
        }
        .padding()
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 12)
        .padding(.horizontal)
    }
    
    private func teamListRow(_ team: Team) -> some View {
        HStack(spacing: 12) {
            Text(team.logo ?? "⚽️")
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(team.name)
                    .foregroundColor(.white)
                if let city = team.city {
                    Text(city)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button {
                var updated = team
                updated.isFavorite = true
                viewModel.updateFavoriteTeam(updated)
            } label: {
                Image(systemName: team.isFavorite ? "star.fill" : "star")
                    .foregroundColor(.footSuccess)
            }
        }
        .padding()
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 12)
    }
}

struct FavoriteTeamEditView: View {
    @ObservedObject var viewModel: FootPlanViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var shortName: String = ""
    @State private var logo: String = "⚽️"
    @State private var city: String = ""
    @State private var stadium: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Team")) {
                    TextField("Name", text: $name)
                    TextField("Short name", text: $shortName)
                    TextField("Emoji logo", text: $logo)
                    TextField("City", text: $city)
                    TextField("Stadium", text: $stadium)
                }
            }
            .navigationTitle("Edit team")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
            }
            .onAppear {
                if let team = viewModel.favoriteTeam {
                    name = team.name
                    shortName = team.shortName
                    logo = team.logo ?? "⚽️"
                    city = team.city ?? ""
                    stadium = team.stadium ?? ""
                }
            }
        }
    }
    
    private func save() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let team = Team(
            id: viewModel.favoriteTeam?.id ?? UUID(),
            name: name,
            shortName: shortName.isEmpty ? name : shortName,
            logo: logo.isEmpty ? "⚽️" : logo,
            city: city.isEmpty ? nil : city,
            stadium: stadium.isEmpty ? nil : stadium,
            isFavorite: true
        )
        if viewModel.favoriteTeam != nil {
            viewModel.updateFavoriteTeam(team)
        } else {
            viewModel.addTeam(team)
            viewModel.updateFavoriteTeam(team)
        }
        dismiss()
    }
}

struct AddTeamView: View {
    @ObservedObject var viewModel: FootPlanViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var shortName: String = ""
    @State private var logo: String = "⚽️"
    @State private var city: String = ""
    @State private var stadium: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New team")) {
                    TextField("Name", text: $name)
                    TextField("Short name", text: $shortName)
                    TextField("Emoji logo", text: $logo)
                    TextField("City", text: $city)
                    TextField("Stadium", text: $stadium)
                }
            }
            .navigationTitle("Add team")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveTeam() }
                }
            }
        }
    }
    
    private func saveTeam() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let team = Team(
            id: UUID(),
            name: trimmed,
            shortName: shortName.isEmpty ? trimmed : shortName,
            logo: logo.isEmpty ? "⚽️" : logo,
            city: city.isEmpty ? nil : city,
            stadium: stadium.isEmpty ? nil : stadium,
            isFavorite: false
        )
        
        viewModel.addTeam(team)
        dismiss()
    }
}

