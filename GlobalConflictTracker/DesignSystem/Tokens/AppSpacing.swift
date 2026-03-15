import SwiftUI

enum AppSpacing {
    /// 4pt — micro spacing
    static let xs: CGFloat = 4
    /// 8pt — compact spacing
    static let sm: CGFloat = 8
    /// 16pt — standard spacing
    static let md: CGFloat = 16
    /// 24pt — section spacing
    static let lg: CGFloat = 24
    /// 32pt — large section spacing
    static let xl: CGFloat = 32
    /// 48pt — extra large
    static let xxl: CGFloat = 48

    // MARK: - Corner Radius
    /// Small radius for badges, tags (4pt)
    static let radiusSmall: CGFloat = 4
    /// Medium radius for buttons (8pt)
    static let radiusMedium: CGFloat = 8
    /// Large radius for cards, sheets (12pt)
    static let radiusLarge: CGFloat = 12
    /// Extra large radius for bottom sheets (16pt)
    static let radiusXL: CGFloat = 16

    // MARK: - Touch Targets
    /// Minimum touch target (44pt — Apple HIG)
    static let minTouchTarget: CGFloat = 44
}
