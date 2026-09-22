import Foundation

/// Port de lecture des profils. Les erreurs réutilisent `AuthError` : un 401
/// sur `/profiles` signifie que la session a expiré, et l'app doit repasser par
/// la connexion plutôt qu'afficher une grille vide.
public protocol ProfileClient: Sendable {
  func profiles() async throws(AuthError) -> [Profile]
}

public struct InMemoryProfileClient: ProfileClient {
  private let stored: [Profile]
  private let failure: AuthError?

  public init(profiles: [Profile] = [], failure: AuthError? = nil) {
    self.stored = profiles
    self.failure = failure
  }

  public func profiles() async throws(AuthError) -> [Profile] {
    if let failure { throw failure }
    return stored
  }
}
