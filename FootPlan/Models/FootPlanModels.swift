import Foundation
import SwiftUI

// MARK: - Colors

extension Color {
    static let footBackground = Color(red: 0.078, green: 0.106, blue: 0.122) // #141B1F
    static let footSuccess = Color(red: 0.067, green: 0.914, blue: 0.306) // #11E94E
    static let footCard = Color(red: 0.137, green: 0.188, blue: 0.212) // #233036
}

// MARK: - Enums

enum MatchResult: String, CaseIterable, Codable {
    case notPlayed = "Не сыгран"
    case win = "Победа"
    case draw = "Ничья"
    case loss = "Поражение"
    
    var title: String {
        switch self {
        case .notPlayed:
            return "Not played"
        case .win:
            return "Win"
        case .draw:
            return "Draw"
        case .loss:
            return "Loss"
        }
    }
    
    var color: Color {
        switch self {
        case .win:
            return .footSuccess
        case .draw:
            return .gray
        case .loss:
            return .footSuccess.opacity(0.5)
        case .notPlayed:
            return .footCard
        }
    }
    
    var icon: String {
        switch self {
        case .win:
            return "trophy.fill"
        case .draw:
            return "equal"
        case .loss:
            return "xmark"
        case .notPlayed:
            return "calendar"
        }
    }
}

enum Competition: String, CaseIterable, Codable {
    case league = "Чемпионат"
    case cup = "Кубок"
    case friendly = "Товарищеский"
    case europe = "Еврокубок"
    case playoff = "Плей-офф"
    
    var icon: String {
        switch self {
        case .league:
            return "sportscourt.fill"
        case .cup:
            return "cup.and.saucer.fill"
        case .friendly:
            return "person.2"
        case .europe:
            return "star.fill"
        case .playoff:
            return "flag.checkered"
        }
    }
    
    var englishName: String {
        switch self {
        case .league:
            return "League"
        case .cup:
            return "Cup"
        case .friendly:
            return "Friendly"
        case .europe:
            return "European cup"
        case .playoff:
            return "Play-off"
        }
    }
}

enum Venue: String, CaseIterable, Codable {
    case home = "Дома"
    case away = "В гостях"
    case neutral = "Нейтральное поле"
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .away:
            return "airplane"
        case .neutral:
            return "map.fill"
        }
    }
    
    var englishName: String {
        switch self {
        case .home:
            return "Home"
        case .away:
            return "Away"
        case .neutral:
            return "Neutral ground"
        }
    }
}

// MARK: - Models

struct Team: Identifiable, Codable {
    let id: UUID
    var name: String
    var shortName: String
    var logo: String?
    var city: String?
    var stadium: String?
    var isFavorite: Bool
}

struct GoalScorer: Identifiable, Codable {
    let id: UUID
    var playerName: String
    var minute: Int
    var isPenalty: Bool
    var isOwnGoal: Bool
}

struct Assist: Identifiable, Codable {
    let id: UUID
    var playerName: String
    var minute: Int
}

struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var number: Int
    var position: String
    var isCaptain: Bool
}

struct Substitution: Identifiable, Codable {
    let id: UUID
    var playerOut: String
    var playerIn: String
    var minute: Int
}

struct Card: Identifiable, Codable {
    let id: UUID
    var playerName: String
    var minute: Int
    var isRed: Bool
}

struct Match: Identifiable, Codable {
    let id: UUID
    var date: Date
    var competition: Competition
    var opponent: Team
    var venue: Venue
    var ourScore: Int?
    var opponentScore: Int?
    var goalscorers: [GoalScorer]
    var assists: [Assist]
    var lineup: [Player]?
    var substitutions: [Substitution]?
    var yellowCards: [Card]?
    var redCards: [Card]?
    var notes: String?
    var tags: [String]
    var isFavorite: Bool
    let createdAt: Date
    
    var result: MatchResult {
        guard let our = ourScore, let opp = opponentScore else { return .notPlayed }
        if our > opp { return .win }
        if our < opp { return .loss }
        return .draw
    }
}

struct PlayerStats: Identifiable, Codable {
    let id: UUID
    var playerName: String
    var goals: Int
    var assists: Int
    var matches: Int
    var yellowCards: Int
    var redCards: Int
}

struct HeadToHead: Identifiable, Codable {
    let id: UUID
    var opponentName: String
    var wins: Int
    var draws: Int
    var losses: Int
    var goalsFor: Int
    var goalsAgainst: Int
    
    var totalMatches: Int {
        wins + draws + losses
    }
}

