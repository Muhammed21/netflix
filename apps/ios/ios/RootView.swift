import AppCore
import SwiftUI

/// Enchaîne splash → onboarding → connexion → accueil. Seul endroit qui décide
/// du parcours : l'onboarding est sauté s'il a déjà été vu, et la connexion
/// l'est si une session valide subsiste.
struct RootView: View {
  private enum Step: Equatable {
    case splash
    case onboarding
    case signIn
    case home(AuthenticatedUser)
  }

  let storage: OnboardingStorage
  let client: AuthClient

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
      case .signIn:
        SignInView(client: client, onSignedIn: { step = .home($0) })
      case .home(let user):
        HomePlaceholderView(user: user)
      }
    }
    .animation(.easeInOut(duration: 0.4), value: step)
  }

  private func finishSplash() {
    guard step == .splash else { return }
    guard storage.hasCompletedOnboarding else {
      step = .onboarding
      return
    }
    Task { await resolveSession() }
  }

  private func completeOnboarding() {
    storage.markOnboardingCompleted()
    Task { await resolveSession() }
  }

  /// Le cookie de session est conservé par URLSession entre les lancements ;
  /// on demande au serveur s'il tient toujours plutôt que de le supposer.
  private func resolveSession() async {
    if let user = await client.currentUser() {
      step = .home(user)
    } else {
      step = .signIn
    }
  }
}

#Preview("Premier lancement") {
  RootView(storage: InMemoryOnboardingStorage(), client: InMemoryAuthClient())
}

#Preview("Session active") {
  RootView(
    storage: InMemoryOnboardingStorage(hasCompletedOnboarding: true),
    client: InMemoryAuthClient(
      signedInAs: AuthenticatedUser(id: "1", email: "viewer@netflix.test", name: "Viewer")
    )
  )
}
