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
    case profileSelection
    case home(Profile)
    case startupFailed(String)
  }

  let storage: OnboardingStorage
  let client: AuthClient
  let profileClient: ProfileClient

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
        SignInView(client: client, onSignedIn: { _ in step = .profileSelection })
      case .profileSelection:
        ProfileSelectionView(
          client: profileClient,
          onSelect: { step = .home($0) },
          onSessionExpired: { step = .signIn }
        )
      case .home(let profile):
        HomePlaceholderView(profile: profile)
      case .startupFailed(let message):
        StartupFailureView(message: message) { Task { await resolveSession() } }
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
    do {
      // Le choix du profil est redemandé à chaque lancement, comme chez
      // Netflix : il n'a pas à être persisté.
      step = try await client.currentUser() == nil ? .signIn : .profileSelection
    } catch {
      // Une panne réseau n'est pas une déconnexion : afficher l'écran de
      // connexion ferait croire à l'utilisateur qu'il a été déconnecté, et il
      // saisirait ses identifiants pour rien.
      step = .startupFailed(error.message)
    }
  }
}

#Preview("Premier lancement") {
  RootView(
    storage: InMemoryOnboardingStorage(),
    client: InMemoryAuthClient(),
    profileClient: InMemoryProfileClient()
  )
}

#Preview("Session active") {
  RootView(
    storage: InMemoryOnboardingStorage(hasCompletedOnboarding: true),
    client: InMemoryAuthClient(
      signedInAs: AuthenticatedUser(id: "1", email: "viewer@netflix.test", name: "Viewer")
    ),
    profileClient: InMemoryProfileClient(profiles: [
      Profile(id: "1", name: "Profil 1", avatar: .blue, isKids: false, position: 0)
    ])
  )
}
