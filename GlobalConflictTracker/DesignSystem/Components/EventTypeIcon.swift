import SwiftUI

/// Icon differentiated by event type for map markers and lists
/// Naval ⚓, Cyber 💻, Airspace ✈, Diplomatic 🏛
/// Used in: Map markers, Event Detail, Intel Feed
struct EventTypeIcon: View {
    let eventType: EventType
    var size: CGFloat = 24
    var showBackground: Bool = true

    var body: some View {
        ZStack {
            if showBackground {
                Circle()
                    .fill(eventType.color.opacity(0.2))
                    .frame(width: size + 12, height: size + 12)
            }

            Image(systemName: eventType.icon)
                .font(.system(size: size * 0.6, weight: .semibold))
                .foregroundStyle(eventType.color)
        }
        .accessibilityLabel(eventType.accessibilityLabel)
    }
}

#Preview("Event Type Icons") {
    HStack(spacing: 20) {
        ForEach(EventType.allCases, id: \.self) { type in
            VStack(spacing: 8) {
                EventTypeIcon(eventType: type)
                Text(type.rawValue)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .textCase(.uppercase)
            }
        }
    }
    .padding()
    .background(AppColors.background)
    .preferredColorScheme(.dark)
}
