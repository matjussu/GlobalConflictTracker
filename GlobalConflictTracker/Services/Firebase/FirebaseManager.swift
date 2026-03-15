import Foundation
import FirebaseFirestore

/// Centralized Firebase configuration and Firestore access
final class FirebaseManager {
    static let shared = FirebaseManager()

    let db: Firestore

    private init() {
        db = Firestore.firestore()
    }

    // MARK: - Collection References

    var eventsCollection: CollectionReference {
        db.collection("events")
    }

    var factionsCollection: CollectionReference {
        db.collection("factions")
    }

    var intelReportsCollection: CollectionReference {
        db.collection("intelReports")
    }

    var regionsCollection: CollectionReference {
        db.collection("regions")
    }
}
