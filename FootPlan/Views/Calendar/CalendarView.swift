import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: FootPlanViewModel
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date?
    @State private var selectedMatch: Match?
    
    private var daysInMonth: [Date?] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return []
        }
        
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmpty = (weekday + 5) % 7
        
        var result: [Date?] = Array(repeating: nil, count: leadingEmpty)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                result.append(date)
            }
        }
        return result
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: currentMonth).capitalized
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.footBackground.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Calendar")
                        .font(.largeTitle.bold())
                        .foregroundColor(.footSuccess)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    VStack {
                        HStack {
                            Button(action: previousMonth) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.footSuccess)
                            }
                            
                            Spacer()
                            
                            Text(monthYearString)
                                .font(.title2)
                                .foregroundColor(.footSuccess)
                            
                            Spacer()
                            
                            Button(action: nextMonth) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.footSuccess)
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                                Text(day)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, day in
                                if let date = day {
                                    CalendarDayCell(
                                        date: date,
                                        hasMatch: viewModel.hasMatch(on: date),
                                        matchResult: viewModel.matchResult(on: date)
                                    )
                                    .onTapGesture {
                                        selectedDate = date
                                    }
                                } else {
                                    Color.clear
                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.footCard)
                    .footCardStyle(cornerRadius: 12)
                    .padding(.horizontal)
                    
                    if let selectedDate = selectedDate {
                        VStack(alignment: .leading) {
                            Text(formattedDate(selectedDate))
                                .font(.headline)
                                .foregroundColor(.footSuccess)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.matchesOnDate(selectedDate)) { match in
                                SmallMatchCard(match: match)
                                    .onTapGesture {
                                        selectedMatch = match
                                    }
                            }
                        }
                        .padding(.top)
                    }
                    
                    Spacer()
                }
            }
            .sheet(item: $selectedMatch) { match in
                MatchDetailView(match: match, viewModel: viewModel)
            }
            .navigationBarHidden(true)
        }
    }
    
    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
        }
    }
}

