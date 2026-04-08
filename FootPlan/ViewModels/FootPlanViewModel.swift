import Foundation
import Combine

final class FootPlanViewModel: ObservableObject {
    // MARK: - Published
    @Published var matches: [Match] = []
    @Published var teams: [Team] = []
    @Published var selectedFilter: Filter = .upcoming
    @Published var competitionFilter: Competition?
    @Published var venueFilter: Venue?
    @Published var tagFilter: String?
    @Published var sortOption: SortOption = .byDate
    @Published var players: [Player] = []
    
    enum Filter {
        case upcoming, past, all
    }
    
    enum SortOption {
        case byDate
        case byOpponent
        case favoritesFirst
    }
    
    // MARK: - Computed stats
    var totalMatches: Int {
        matches.count
    }
    
    var winsCount: Int {
        matches.filter { $0.result == .win }.count
    }
    
    var drawsCount: Int {
        matches.filter { $0.result == .draw }.count
    }
    
    var lossesCount: Int {
        matches.filter { $0.result == .loss }.count
    }
    
    var totalGoals: Int {
        matches.compactMap { $0.ourScore }.reduce(0, +)
    }
    
    var totalGoalsConceded: Int {
        matches.compactMap { $0.opponentScore }.reduce(0, +)
    }
    
    var averageGoalsFor: Double {
        guard totalMatches > 0 else { return 0 }
        return Double(totalGoals) / Double(totalMatches)
    }
    
    var averageGoalsAgainst: Double {
        guard totalMatches > 0 else { return 0 }
        return Double(totalGoalsConceded) / Double(totalMatches)
    }
    
    var cleanSheetsCount: Int {
        matches.filter { ($0.opponentScore ?? 0) == 0 && $0.result != .notPlayed }.count
    }
    
    var winRate: Double {
        guard totalMatches > 0 else { return 0 }
        return Double(winsCount) / Double(totalMatches)
    }
    
    var recentForm: String {
        let last5 = matches
            .filter { $0.result != .notPlayed }
            .sorted { $0.date > $1.date }
            .prefix(5)
        
        return last5.map { match in
            switch match.result {
            case .win: return "✅"
            case .draw: return "➖"
            case .loss: return "❌"
            case .notPlayed: return "⏳"
            }
        }.joined()
    }
    
    var filteredMatches: [Match] {
        let now = Date()
        var result = matches
        
        switch selectedFilter {
        case .upcoming:
            result = result.filter { $0.date >= now && $0.result == .notPlayed }
        case .past:
            result = result.filter { $0.date < now || $0.result != .notPlayed }
        case .all:
            break
        }
        
        if let competitionFilter {
            result = result.filter { $0.competition == competitionFilter }
        }
        
        if let venueFilter {
            result = result.filter { $0.venue == venueFilter }
        }
        
        if let tagFilter, !tagFilter.isEmpty {
            result = result.filter { $0.tags.contains(tagFilter) }
        }
        
        switch sortOption {
        case .byDate:
            result = result.sorted { $0.date < $1.date }
        case .byOpponent:
            result = result.sorted {
                if $0.opponent.name == $1.opponent.name {
                    return $0.date < $1.date
                }
                return $0.opponent.name < $1.opponent.name
            }
        case .favoritesFirst:
            result = result.sorted {
                if $0.isFavorite == $1.isFavorite {
                    return $0.date < $1.date
                }
                return $0.isFavorite && !$1.isFavorite
            }
        }
        
        return result
    }
    
    var topScorers: [PlayerStats] {
        var stats: [String: PlayerStats] = [:]
        
        for match in matches {
            for scorer in match.goalscorers where !scorer.isOwnGoal {
                if var stat = stats[scorer.playerName] {
                    stat.goals += 1
                    stats[scorer.playerName] = stat
                } else {
                    stats[scorer.playerName] = PlayerStats(
                        id: UUID(),
                        playerName: scorer.playerName,
                        goals: 1,
                        assists: 0,
                        matches: 0,
                        yellowCards: 0,
                        redCards: 0
                    )
                }
            }
            
            for assist in match.assists {
                if var stat = stats[assist.playerName] {
                    stat.assists += 1
                    stats[assist.playerName] = stat
                } else {
                    stats[assist.playerName] = PlayerStats(
                        id: UUID(),
                        playerName: assist.playerName,
                        goals: 0,
                        assists: 1,
                        matches: 0,
                        yellowCards: 0,
                        redCards: 0
                    )
                }
            }
        }
        
        return stats.values.sorted { $0.goals > $1.goals }
    }
    
    var topAssisters: [PlayerStats] {
        topScorers.sorted { $0.assists > $1.assists }
    }
    
    var headToHead: [HeadToHead] {
        var dict: [String: HeadToHead] = [:]
        
        for match in matches where match.result != .notPlayed {
            let opponentName = match.opponent.name
            
            if var h2h = dict[opponentName] {
                switch match.result {
                case .win:
                    h2h.wins += 1
                    h2h.goalsFor += match.ourScore ?? 0
                    h2h.goalsAgainst += match.opponentScore ?? 0
                case .draw:
                    h2h.draws += 1
                    h2h.goalsFor += match.ourScore ?? 0
                    h2h.goalsAgainst += match.opponentScore ?? 0
                case .loss:
                    h2h.losses += 1
                    h2h.goalsFor += match.ourScore ?? 0
                    h2h.goalsAgainst += match.opponentScore ?? 0
                case .notPlayed:
                    break
                }
                dict[opponentName] = h2h
            } else {
                var wins = 0, draws = 0, losses = 0
                switch match.result {
                case .win: wins = 1
                case .draw: draws = 1
                case .loss: losses = 1
                case .notPlayed: break
                }
                
                dict[opponentName] = HeadToHead(
                    id: UUID(),
                    opponentName: opponentName,
                    wins: wins,
                    draws: draws,
                    losses: losses,
                    goalsFor: match.ourScore ?? 0,
                    goalsAgainst: match.opponentScore ?? 0
                )
            }
        }
        
        return dict.values.sorted { $0.wins > $1.wins }
    }
    
    var favoriteTeam: Team? {
        teams.first(where: { $0.isFavorite })
    }
    
    // MARK: - Calendar helpers
    func hasMatch(on date: Date) -> Bool {
        let calendar = Calendar.current
        return matches.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func matchResult(on date: Date) -> MatchResult? {
        let calendar = Calendar.current
        return matches.first { calendar.isDate($0.date, inSameDayAs: date) }?.result
    }
    
    func matchesOnDate(_ date: Date) -> [Match] {
        let calendar = Calendar.current
        return matches
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }
    
    // MARK: - CRUD
    func addMatch(_ match: Match) {
        matches.append(match)
        
        if !teams.contains(where: { $0.id == match.opponent.id }) {
            teams.append(match.opponent)
        }
        
        saveToUserDefaults()
    }
    
    func updateMatch(_ match: Match) {
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            matches[index] = match
            saveToUserDefaults()
        }
    }
    
    func deleteMatch(_ match: Match) {
        matches.removeAll { $0.id == match.id }
        saveToUserDefaults()
    }
    
    func toggleFavoriteMatch(_ match: Match) {
        if let index = matches.firstIndex(where: { $0.id == match.id }) {
            matches[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }
    
    func addTeam(_ team: Team) {
        teams.append(team)
        saveToUserDefaults()
    }
    
    func updateFavoriteTeam(_ team: Team) {
        if let index = teams.firstIndex(where: { $0.id == team.id }) {
            teams.indices.forEach { teams[$0].isFavorite = false }
            teams[index] = team
            teams[index].isFavorite = true
            saveToUserDefaults()
        }
    }
    
    // MARK: - Persistence
    private let matchesKey = "footplan_matches"
    private let teamsKey = "footplan_teams"
    private let playersKey = "footplan_players"
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(matches) {
            UserDefaults.standard.set(encoded, forKey: matchesKey)
        }
        if let encoded = try? JSONEncoder().encode(teams) {
            UserDefaults.standard.set(encoded, forKey: teamsKey)
        }
        if let encoded = try? JSONEncoder().encode(players) {
            UserDefaults.standard.set(encoded, forKey: playersKey)
        }
    }
    
    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: matchesKey),
           let decoded = try? JSONDecoder().decode([Match].self, from: data) {
            matches = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: teamsKey),
           let decoded = try? JSONDecoder().decode([Team].self, from: data) {
            teams = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: playersKey),
           let decoded = try? JSONDecoder().decode([Player].self, from: data) {
            players = decoded
        }
        
        if matches.isEmpty {
            loadDemoData()
        }
    }
    
    func clearAllData() {
        matches = []
        teams = []
        players = []
        
        UserDefaults.standard.removeObject(forKey: matchesKey)
        UserDefaults.standard.removeObject(forKey: teamsKey)
        UserDefaults.standard.removeObject(forKey: playersKey)
    }
    
    private func loadDemoData() {
        let opponent = Team(
            id: UUID(),
            name: "Zenit",
            shortName: "Zenit",
            logo: "⚽",
            city: "Saint Petersburg",
            stadium: "Gazprom Arena",
            isFavorite: false
        )
        
        teams = [opponent]
        
        let match1 = Match(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 7),
            competition: .league,
            opponent: opponent,
            venue: .home,
            ourScore: 2,
            opponentScore: 1,
            goalscorers: [
                GoalScorer(id: UUID(), playerName: "Ivanov", minute: 35, isPenalty: false, isOwnGoal: false),
                GoalScorer(id: UUID(), playerName: "Petrov", minute: 78, isPenalty: false, isOwnGoal: false)
            ],
            assists: [
                Assist(id: UUID(), playerName: "Sidorov", minute: 35)
            ],
            lineup: nil,
            substitutions: nil,
            yellowCards: nil,
            redCards: nil,
            notes: "Comeback win",
            tags: ["Big win"],
            isFavorite: true,
            createdAt: Date()
        )
        
        let match2 = Match(
            id: UUID(),
            date: Date().addingTimeInterval(86400 * 3),
            competition: .cup,
            opponent: opponent,
            venue: .away,
            ourScore: nil,
            opponentScore: nil,
            goalscorers: [],
            assists: [],
            lineup: nil,
            substitutions: nil,
            yellowCards: nil,
            redCards: nil,
            notes: "Important match",
            tags: [],
            isFavorite: false,
            createdAt: Date()
        )
        
        matches = [match1, match2]
    }
}

