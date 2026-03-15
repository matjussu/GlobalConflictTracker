import SwiftUI

struct OnboardingContainerView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                if viewModel.currentStep > 1 {
                    Button {
                        viewModel.previousStep()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(AppColors.textPrimary)
                            .frame(minWidth: AppSpacing.minTouchTarget, minHeight: AppSpacing.minTouchTarget)
                    }
                } else {
                    Spacer().frame(width: AppSpacing.minTouchTarget)
                }

                Spacer()

                Text("PROTOCOL: SETUP")
                    .font(AppTypography.labelLarge)
                    .tracking(AppTypography.trackingWide)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                // Skip button
                Button {
                    skipOnboarding()
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(minWidth: AppSpacing.minTouchTarget, minHeight: AppSpacing.minTouchTarget)
                }
            }
            .padding(.horizontal, AppSpacing.sm)

            // Progress indicator
            HStack(spacing: AppSpacing.md) {
                HStack(spacing: 0) {
                    Text("STEP 0\(viewModel.currentStep)")
                        .font(AppTypography.labelSmall)
                        .tracking(AppTypography.trackingWide)
                        .foregroundStyle(AppColors.textPrimary)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(AppColors.surface)
                                .frame(height: 3)

                            Rectangle()
                                .fill(AppColors.accent)
                                .frame(width: geometry.size.width * viewModel.progress, height: 3)
                                .animation(.easeInOut, value: viewModel.progress)
                        }
                    }
                    .frame(height: 3)
                    .padding(.leading, AppSpacing.sm)
                }

                Text("INITIALIZATION: \(viewModel.progressPercentage)%")
                    .font(AppTypography.labelSmall)
                    .tracking(AppTypography.trackingNormal)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.sm)

            // Step content
            TabView(selection: $viewModel.currentStep) {
                Step1_MissionBriefingView(viewModel: viewModel)
                    .tag(1)

                Step2_NotificationConfigView(viewModel: viewModel)
                    .tag(2)

                Step3_RegionSelectionView(viewModel: viewModel)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentStep)

            // Bottom CTA
            VStack(spacing: AppSpacing.sm) {
                if viewModel.currentStep == viewModel.totalSteps {
                    TacticalButton(title: "INITIALIZE FEED", icon: "arrow.right") {
                        viewModel.completeOnboarding()
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }
                    .disabled(!viewModel.canProceed)
                    .opacity(viewModel.canProceed ? 1.0 : 0.5)
                } else {
                    TacticalButton(title: "CONTINUE", icon: "arrow.right") {
                        viewModel.nextStep()
                    }
                }

                if viewModel.currentStep < viewModel.totalSteps {
                    Button("Skip Setup") {
                        skipOnboarding()
                    }
                    .font(AppTypography.bodySmall)
                    .foregroundStyle(AppColors.textTertiary)
                    .frame(minHeight: AppSpacing.minTouchTarget)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
        }
        .background(AppColors.background.ignoresSafeArea())
    }

    private func skipOnboarding() {
        viewModel.completeOnboarding()
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingContainerView(hasCompletedOnboarding: .constant(false))
        .preferredColorScheme(.dark)
}
