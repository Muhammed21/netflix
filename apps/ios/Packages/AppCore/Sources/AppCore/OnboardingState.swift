/// Machine à états de l'onboarding. Volontairement une valeur pure, sans
/// dépendance ni effet de bord : elle se teste sans bouchon ni simulateur.
public struct OnboardingState: Equatable, Sendable {
  public private(set) var currentIndex: Int

  private let pages: [OnboardingPage]

  public init(pages: [OnboardingPage] = OnboardingPage.all) {
    self.pages = pages
    self.currentIndex = 0
  }

  public var currentPage: OnboardingPage {
    pages[currentIndex]
  }

  public var isOnLastPage: Bool {
    currentIndex == pages.count - 1
  }

  public var callToAction: String {
    isOnLastPage ? "Commencer" : "Suivant"
  }

  /// Avance d'une page. Sur la dernière page, ne fait rien : c'est au bouton
  /// « Commencer » de terminer le parcours, pas au défilement de déborder.
  public mutating func advance() {
    guard isOnLastPage == false else { return }
    currentIndex += 1
  }

  public mutating func goTo(index: Int) {
    guard pages.indices.contains(index) else { return }
    currentIndex = index
  }
}
