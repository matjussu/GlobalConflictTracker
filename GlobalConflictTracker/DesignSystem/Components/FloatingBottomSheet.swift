import SwiftUI

/// Draggable bottom sheet with blur overlay
/// Supports expand/collapse/dismiss gestures
/// Used in: Tactical Map (alert sheet)
struct FloatingBottomSheet<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder let content: () -> Content

    @State private var dragOffset: CGFloat = 0
    @State private var sheetHeight: CGFloat = 0

    private let dismissThreshold: CGFloat = 100

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if isPresented {
                    // Dimmed backdrop
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35)) {
                                isPresented = false
                            }
                        }
                        .transition(.opacity)

                    // Sheet
                    VStack(spacing: 0) {
                        // Drag handle
                        Capsule()
                            .fill(AppColors.textTertiary)
                            .frame(width: 36, height: 5)
                            .padding(.top, AppSpacing.sm)
                            .padding(.bottom, AppSpacing.md)

                        content()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: AppSpacing.radiusXL)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.radiusXL)
                                    .fill(AppColors.surfaceElevated.opacity(0.85))
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusXL))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.radiusXL)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + AppSpacing.sm)
                    .offset(y: max(0, dragOffset))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                if value.translation.height > dismissThreshold {
                                    withAnimation(.spring(response: 0.35)) {
                                        isPresented = false
                                    }
                                }
                                withAnimation(.spring(response: 0.3)) {
                                    dragOffset = 0
                                }
                            }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPresented)
        }
        .ignoresSafeArea()
    }
}

#Preview("Bottom Sheet") {
    struct PreviewWrapper: View {
        @State var isShown = true
        var body: some View {
            ZStack {
                AppColors.background.ignoresSafeArea()
                Button("Show Sheet") { isShown = true }
                    .foregroundStyle(.white)

                FloatingBottomSheet(isPresented: $isShown) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            SeverityBadge(severity: .critical)
                            Text("IMMEDIATE ALERT")
                                .font(AppTypography.caption)
                                .tracking(AppTypography.trackingWide)
                                .foregroundStyle(AppColors.accent)
                        }
                        Text("Naval Deployment in Red Sea")
                            .font(AppTypography.heading1)
                            .foregroundStyle(.white)
                        Text("Multiple destroyer-class vessels detected entering sector 7-G.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                        TacticalButton(title: "View Full Intel Report", style: .secondary) {}
                    }
                    .padding(AppSpacing.md)
                    .padding(.bottom, AppSpacing.md)
                }
            }
        }
    }
    return PreviewWrapper()
        .preferredColorScheme(.dark)
}
