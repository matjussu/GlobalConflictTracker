import SwiftUI
import SceneKit

struct GlobeView: View {
    @State private var viewModel = GlobeViewModel()

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            GlobeSceneView(viewModel: viewModel)
                .ignoresSafeArea()

            // Header overlay
            VStack {
                headerOverlay
                Spacer()

                if let event = viewModel.selectedEvent {
                    selectedEventCard(event)
                }
            }
        }
        .task { await viewModel.loadEvents() }
    }

    private var headerOverlay: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppColors.accent)
                        .frame(width: 6, height: 6)

                    Text("GLOBE OVERVIEW")
                        .font(AppTypography.labelLarge)
                        .tracking(AppTypography.trackingWide)
                        .foregroundStyle(AppColors.textPrimary)
                }

                Text("\(viewModel.events.count) ACTIVE EVENTS")
                    .font(AppTypography.caption)
                    .tracking(AppTypography.trackingWide)
                    .foregroundStyle(AppColors.textTertiary)
            }

            Spacer()
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
    }

    private func selectedEventCard(_ event: ConflictEvent) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                SeverityBadge(severity: event.severity)

                Text(event.title)
                    .font(AppTypography.heading3)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Spacer()

                Button {
                    viewModel.clearSelection()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.textTertiary)
                        .frame(width: 28, height: 28)
                        .background(AppColors.surface)
                        .clipShape(Circle())
                }
            }

            Text(event.summary)
                .font(AppTypography.bodySmall)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)

            NavigationLink(value: event) {
                HStack {
                    Text("VIEW DETAILS")
                        .font(AppTypography.labelSmall)
                        .tracking(AppTypography.trackingWide)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(AppColors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColors.accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusSmall))
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.radiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.radiusMedium)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .padding(.horizontal, AppSpacing.md)
        .padding(.bottom, AppSpacing.md)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedEvent?.id)
    }
}

// MARK: - SceneKit UIViewRepresentable

struct GlobeSceneView: UIViewRepresentable {
    let viewModel: GlobeViewModel

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame: .zero)
        scnView.backgroundColor = UIColor(AppColors.background)
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = false
        scnView.isJitteringEnabled = true

        let globeScene = context.coordinator.globeScene
        scnView.scene = globeScene.scene
        scnView.pointOfView = globeScene.cameraNode

        // Gesture recognizers
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        scnView.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        scnView.addGestureRecognizer(panGesture)

        // Start auto-rotation
        globeScene.startAutoRotation()

        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        let globeScene = context.coordinator.globeScene
        globeScene.updateMarkers(events: viewModel.events)
        globeScene.updateArcs(events: viewModel.trajectoryEvents)
        context.coordinator.viewModel = viewModel
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject {
        let globeScene: GlobeScene
        var viewModel: GlobeViewModel
        private var idleTimer: Timer?
        private var lastPanPoint: CGPoint = .zero

        init(viewModel: GlobeViewModel) {
            self.viewModel = viewModel
            self.globeScene = GlobeScene()
            super.init()
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView = gesture.view as? SCNView else { return }
            let location = gesture.location(in: scnView)

            let hitResults = scnView.hitTest(location, options: [
                .searchMode: SCNHitTestSearchMode.closest.rawValue
            ])

            for result in hitResults {
                if let eventID = globeScene.eventID(for: result.node) {
                    viewModel.selectEvent(id: eventID)
                    return
                }
            }

            // Tapped empty space — clear selection
            viewModel.clearSelection()
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let pivot = globeScene.globePivotNode

            switch gesture.state {
            case .began:
                globeScene.stopAutoRotation()
                idleTimer?.invalidate()
                lastPanPoint = gesture.location(in: gesture.view)

            case .changed:
                let currentPoint = gesture.location(in: gesture.view)
                let deltaX = Float(currentPoint.x - lastPanPoint.x) * 0.005
                let deltaY = Float(currentPoint.y - lastPanPoint.y) * 0.005

                pivot.eulerAngles.y += deltaX

                // Clamp vertical rotation to ±70 degrees
                let newX = pivot.eulerAngles.x + deltaY
                let maxAngle: Float = 70.0 * .pi / 180.0
                pivot.eulerAngles.x = max(-maxAngle, min(maxAngle, newX))

                lastPanPoint = currentPoint

            case .ended, .cancelled:
                // Resume auto-rotation after 3 seconds idle
                idleTimer?.invalidate()
                idleTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 1.0
                    self?.globeScene.startAutoRotation()
                    SCNTransaction.commit()
                }

            default:
                break
            }
        }
    }
}

#Preview {
    NavigationStack {
        GlobeView()
    }
    .preferredColorScheme(.dark)
}
