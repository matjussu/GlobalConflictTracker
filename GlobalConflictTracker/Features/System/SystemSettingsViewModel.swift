import Foundation
import Observation

@Observable
final class SystemSettingsViewModel {

    var notificationsEnabled: Bool
    var criticalAlertsEnabled: Bool
    var selectedRegionIDs: Set<String>
    var availableRegions: [OperationalRegion] = SampleData.regions

    // Dev tools
    var isSeedingInProgress = false
    var seedResult: String?

    var useMockServices: Bool {
        get { ServiceContainer.shared.useMockServices }
        set { ServiceContainer.shared.useMockServices = newValue }
    }

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

    func seedFirestore() async {
        isSeedingInProgress = true
        seedResult = nil
        do {
            try await ServiceContainer.shared.seedFirestore()
            seedResult = "Seeding complete — 4 events, 6 factions, 4 reports, 4 regions pushed."
        } catch {
            seedResult = "Seed failed: \(error.localizedDescription)"
        }
        isSeedingInProgress = false
    }
}
