//
//  ContentView.swift
//  FootPlan
//
//  Created by Роман Главацкий on 31.03.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FootPlanViewModel()
    @State private var selectedTab = 0
    @AppStorage("onboarding_completed") private var onboardingCompleted = false
    
    var body: some View {
        Group {
            if onboardingCompleted {
                TabView(selection: $selectedTab) {
                    HomeView(viewModel: viewModel)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    FavoriteTeamView(viewModel: viewModel)
                        .tabItem {
                            Label("Team", systemImage: "star.fill")
                        }
                        .tag(1)
                    
                    PlayersStatsView(viewModel: viewModel)
                        .tabItem {
                            Label("Players", systemImage: "person.3.fill")
                        }
                        .tag(2)
                    
                    HeadToHeadView(viewModel: viewModel)
                        .tabItem {
                            Label("Head-to-head", systemImage: "chart.bar.fill")
                        }
                        .tag(3)
                    
                    CalendarView(viewModel: viewModel)
                        .tabItem {
                            Label("Calendar", systemImage: "calendar.day.timeline.left")
                        }
                        .tag(4)
                    
                    SettingsView(viewModel: viewModel)
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(5)
                }
            } else {
                OnboardingView(isCompleted: $onboardingCompleted)
            }
        }
        .onAppear { viewModel.loadFromUserDefaults() }
        .accentColor(.footSuccess)
    }
}

#Preview {
    ContentView()
}
