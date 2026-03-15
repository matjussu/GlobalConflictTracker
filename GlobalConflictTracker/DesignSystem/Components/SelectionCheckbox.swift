import SwiftUI

/// Red-accent checkbox for selection lists
/// Used in: Onboarding region selection
struct SelectionCheckbox: View {
    let title: String
    @Binding var isSelected: Bool

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isSelected.toggle()
            }
        } label: {
            HStack(spacing: AppSpacing.md) {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? AppColors.accent : AppColors.textTertiary, lineWidth: 1.5)
                        .frame(width: 22, height: 22)

                    if isSelected {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.accent)
                            .frame(width: 22, height: 22)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(isSelected ? AppColors.surface : AppColors.background)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.radiusLarge)
                    .stroke(isSelected ? AppColors.accent.opacity(0.5) : AppColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .frame(minHeight: AppSpacing.minTouchTarget)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityLabel("\(title), \(isSelected ? "selected" : "not selected")")
    }
}

#Preview("Checkboxes") {
    struct PreviewWrapper: View {
        @State var a = true
        @State var b = true
        @State var c = false
        @State var d = false
        var body: some View {
            VStack(spacing: 8) {
                SelectionCheckbox(title: "Middle East", isSelected: $a)
                SelectionCheckbox(title: "Eastern Europe", isSelected: $b)
                SelectionCheckbox(title: "South China Sea", isSelected: $c)
                SelectionCheckbox(title: "Arctic Circle", isSelected: $d)
            }
            .padding()
            .background(AppColors.background)
        }
    }
    return PreviewWrapper()
        .preferredColorScheme(.dark)
}
