import Foundation

@Observable
final class SystemSettingsViewModel {

    var notificationsEnabled: Bool
    var criticalAlertsEnabled: Bool
    var selectedRegionIDs: Set<String>
    var availableRegions: [OperationalRegion] = SampleData.regions

    init() {
        if let data = UserDefaults.standard.data(forKey: "userPreferences"),
           let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            notificationsEnabled = prefs.notificationsEnabled
            criticalAlertsEnabled = prefs.criticalAlertsEnabled
            selectedRegionIDs = Set(prefs.selectedRegionIDs)
        } else {
            notificationsEnabled = true
            criticalAlertsEnabled = true
            selectedRegionIDs = []
        }
    }

    func toggleRegion(_ id: String) {
        if selectedRegionIDs.contains(id) {
            selectedRegionIDs.remove(id)
        } else {
            selectedRegionIDs.insert(id)
        }
        savePreferences()
    }

    func savePreferences() {
        let preferences = UserPreferences(
            selectedRegionIDs: Array(selectedRegionIDs),
            notificationsEnabled: notificationsEnabled,
            criticalAlertsEnabled: criticalAlertsEnabled
        )
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }

    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
}
