import SwiftUI

extension View {
    /// Adds a meaningful accessibility label and hint for interactive elements
    func tacticalAccessibility(label: String, hint: String = "") -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint.isEmpty ? "" : hint)
    }

    /// Ensures minimum 44pt touch target
    func ensureMinTouchTarget() -> some View {
        self.frame(
            minWidth: AppSpacing.minTouchTarget,
            minHeight: AppSpacing.minTouchTarget
        )
    }
}
