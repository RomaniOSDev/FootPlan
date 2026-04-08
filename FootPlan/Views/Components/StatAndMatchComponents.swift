import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let cardColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            Text(value)
                .foregroundColor(.white)
                .font(.title2)
                .bold()
        }
        .padding()
        .frame(width: 140, alignment: .leading)
        .background(cardColor)
        .footCardStyle(cornerRadius: 12)
    }
}

struct SmallMatchCard: View {
    let match: Match
    
    var body: some View {
        HStack {
            Image(systemName: match.competition.icon)
                .foregroundColor(.footSuccess)
                .font(.caption)
            
            Text(match.opponent.shortName)
                .foregroundColor(.white)
                .font(.headline)
            
            Spacer()
            
            if match.result != .notPlayed {
                Text("\(match.ourScore ?? 0):\(match.opponentScore ?? 0)")
                    .foregroundColor(match.result == .win ? .footSuccess : .white)
                    .bold()
            } else {
                Text(formattedTime(match.date))
                    .font(.caption)
                    .foregroundColor(.footSuccess)
            }
            
            Image(systemName: match.venue.icon)
                .foregroundColor(.footSuccess)
                .font(.caption)
        }
        .padding()
        .background(Color.footCard)
        .footCardStyle(cornerRadius: 8)
        .padding(.horizontal)
    }
}

struct CalendarDayCell: View {
    let date: Date
    let hasMatch: Bool
    let matchResult: MatchResult?
    
    var body: some View {
        VStack {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption)
                .foregroundColor(hasMatch ? .footSuccess : .white)
            
            if hasMatch, let result = matchResult, result != .notPlayed {
                Image(systemName: result.icon)
                    .font(.caption2)
                    .foregroundColor(result.color)
            } else if hasMatch {
                Circle()
                    .fill(Color.footSuccess)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}

