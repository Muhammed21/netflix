/// Une page de l'onboarding. Le contenu vit ici plutôt que dans la vue : c'est
/// ce qui permet de le couvrir par des tests sans faire tourner SwiftUI.
public struct OnboardingPage: Equatable, Sendable {
  public let title: String
  public let message: String

  public init(title: String, message: String) {
    self.title = title
    self.message = message
  }

  public static let all: [OnboardingPage] = [
    OnboardingPage(
      title: "Des milliers de titres",
      message: "Films, séries et documentaires, à regarder où que vous soyez."
    ),
    OnboardingPage(
      title: "Regardez hors connexion",
      message: "Téléchargez vos titres favoris et emportez-les partout avec vous."
    ),
    OnboardingPage(
      title: "Un profil par personne",
      message: "Chacun retrouve ses recommandations et sa liste, sur tous les écrans."
    ),
  ]
}
