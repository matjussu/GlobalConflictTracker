import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .map
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    var body: some View {
        if hasCompletedOnboarding {
            mainTabView
        } else {
            OnboardingContainerView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TacticalMapView()
                    .navigationDestination(for: ConflictEvent.self) { event in
                        EventDetailView(event: event)
                    }
                    .navigationDestination(for: Faction.self) { faction in
                        FactionProfileView(faction: faction)
                    }
            }
            .tag(AppTab.map)
            .tabItem {
                AppTab.map.label
            }

            NavigationStack {
                IntelFeedView()
                    .navigationDestination(for: IntelReport.self) { report in
                        IntelReportDetailView(report: report)
                    }
                    .navigationDestination(for: ConflictEvent.self) { event in
                        EventDetailView(event: event)
                    }
            }
            .tag(AppTab.intel)
            .tabItem {
                AppTab.intel.label
            }

            NavigationStack {
                FactionsDirectoryView()
                    .navigationDestination(for: Faction.self) { faction in
                        FactionProfileView(faction: faction)
                    }
                    .navigationDestination(for: ConflictEvent.self) { event in
                        EventDetailView(event: event)
                    }
            }
            .tag(AppTab.factions)
            .tabItem {
                AppTab.factions.label
            }

            NavigationStack {
                SystemSettingsView()
            }
            .tag(AppTab.system)
            .tabItem {
                AppTab.system.label
            }
        }
        .tint(AppColors.accent)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
