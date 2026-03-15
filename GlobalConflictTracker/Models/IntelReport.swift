import Foundation

struct IntelReport: Identifiable, Codable, Hashable {
    var id: String
    var headline: String
    var body: String
    var timestamp: Date
    var sector: String
    var severity: Severity
    var imageURL: String?
    var sourceReliability: SourceReliability
    var relatedEventID: String?
    var category: IntelCategory
    var isRead: Bool = false
}

enum IntelCategory: String, Codable, CaseIterable {
    case chronological
    case highAlert
    case global

    var label: String {
        switch self {
        case .chronological: "CHRONOLOGICAL"
        case .highAlert: "HIGH ALERT"
        case .global: "GLOBAL"
        }
    }
}
