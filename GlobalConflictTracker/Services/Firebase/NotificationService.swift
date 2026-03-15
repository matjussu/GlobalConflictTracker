import Foundation
import Combine
import UserNotifications
import FirebaseMessaging

final class NotificationService: NSObject, ObservableObject {

    @Published var isAuthorized = false

    override init() {
        super.init()
        Messaging.messaging().delegate = self
    }

    /// Request notification permissions
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert])
            await MainActor.run { isAuthorized = granted }
            return granted
        } catch {
            return false
        }
    }

    /// Subscribe to critical alerts topic
    func subscribeToCriticalAlerts() {
        Messaging.messaging().subscribe(toTopic: "critical_alerts")
    }

    /// Unsubscribe from critical alerts topic
    func unsubscribeFromCriticalAlerts() {
        Messaging.messaging().unsubscribe(fromTopic: "critical_alerts")
    }

    /// Subscribe to a specific region's alerts
    func subscribeToRegion(_ regionID: String) {
        Messaging.messaging().subscribe(toTopic: "region_\(regionID)")
    }

    /// Unsubscribe from a specific region
    func unsubscribeFromRegion(_ regionID: String) {
        Messaging.messaging().unsubscribe(fromTopic: "region_\(regionID)")
    }
}

// MARK: - MessagingDelegate

extension NotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("[FCM] Token: \(token)")
    }
}
