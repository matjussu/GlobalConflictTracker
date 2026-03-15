import SwiftUI

@Observable
final class TabRouter {
    var selectedTab: AppTab = .map
    var mapNavigationPath = NavigationPath()
    var intelNavigationPath = NavigationPath()
    var factionsNavigationPath = NavigationPath()

    func navigateToEvent(_ event: ConflictEvent) {
        selectedTab = .map
        mapNavigationPath.append(event)
    }

    func navigateToFaction(_ faction: Faction) {
        selectedTab = .factions
        factionsNavigationPath.append(faction)
    }

    func navigateToReport(_ report: IntelReport) {
        selectedTab = .intel
        intelNavigationPath.append(report)
    }

    func resetNavigation() {
        mapNavigationPath = NavigationPath()
        intelNavigationPath = NavigationPath()
        factionsNavigationPath = NavigationPath()
    }
}
