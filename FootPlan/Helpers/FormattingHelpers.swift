import Foundation

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMMM yyyy, HH:mm"
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter.string(from: date)
}

func formattedShortDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM"
    return formatter.string(from: date)
}

func formattedTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

