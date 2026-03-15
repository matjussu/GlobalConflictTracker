import SwiftUI
import FirebaseCore

@main
struct GlobalConflictTrackerApp: App {

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
