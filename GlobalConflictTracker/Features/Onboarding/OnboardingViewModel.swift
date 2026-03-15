import Foundation
import SwiftUI

@Observable
final class OnboardingViewModel {
    var currentStep = 1
    let totalSteps = 3

    // Step 2: Notification preferences
    var notificationsEnabled = true
    var criticalAlertsEnabled = true

    // Step 3: Region selection
    var selectedRegionIDs: Set<String> = []
    var availableRegions: [OperationalRegion] = SampleData.regions

    var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }

    var progressPercentage: Int {
        Int(progress * 100)
    }

    var canProceed: Bool {
        switch currentStep {
        case 1: true
        case 2: true
        case 3: !selectedRegionIDs.isEmpty
        default: true
        }
    }

    func nextStep() {
        guard currentStep < totalSteps else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep += 1
        }
    }

    func previousStep() {
        guard currentStep > 1 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep -= 1
        }
    }

    func toggleRegion(_ id: String) {
        if selectedRegionIDs.contains(id) {
            selectedRegionIDs.remove(id)
        } else {
            selectedRegionIDs.insert(id)
        }
    }

    func completeOnboarding() {
        let preferences = UserPreferences(
            selectedRegionIDs: Array(selectedRegionIDs),
            notificationsEnabled: notificationsEnabled,
            criticalAlertsEnabled: criticalAlertsEnabled
        )
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
