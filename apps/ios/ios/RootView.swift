import AppCore
import SwiftUI

/// Enchaîne splash → onboarding → accueil. L'onboarding est sauté d'emblée
/// s'il a déjà été complété : c'est le seul endroit qui décide du parcours.
struct RootView: View {
  private enum Step: Equatable {
    case splash
    case onboarding
    case home
  }

  let storage: OnboardingStorage

  @State private var step: Step = .splash

  var body: some View {
    Group {
      switch step {
      case .splash:
        // La sortie du splash est pilotée par la fin de l'animation, pas par un
        // minuteur parallèle qui dériverait de la durée réelle de la vidéo.
        SplashView(onFinished: finishSplash)
      case .onboarding:
        OnboardingView(onFinish: completeOnboarding)
      case .home:
        HomePlaceholderView()
      }
    }
    .animation(.easeInOut(duration: 0.4), value: step)
  }

  private func finishSplash() {
    guard step == .splash else { return }
    step = storage.hasCompletedOnboarding ? .home : .onboarding
  }

  private func completeOnboarding() {
    storage.markOnboardingCompleted()
    step = .home
  }
}

#Preview("Premier lancement") {
  RootView(storage: InMemoryOnboardingStorage())
}

#Preview("Onboarding déjà vu") {
  RootView(storage: InMemoryOnboardingStorage(hasCompletedOnboarding: true))
}
