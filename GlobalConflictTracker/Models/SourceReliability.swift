import SwiftUI

struct SourceReliability: Codable, Hashable {
    var score: Int
    var label: String

    var color: Color {
        AppColors.reliabilityColor(score)
    }
}
