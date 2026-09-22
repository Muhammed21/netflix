import Foundation

public struct AuthenticatedUser: Equatable, Sendable, Decodable {
  public let id: String
  public let email: String
  public let name: String

  public init(id: String, email: String, name: String) {
    self.id = id
    self.email = email
    self.name = name
  }
}

/// Port d'authentification. L'app branche `HTTPAuthClient`, les tests un double.
public protocol AuthClient: Sendable {
  func signIn(email: String, password: String) async throws(AuthError) -> AuthenticatedUser
  /// `nil` signifie « personne n'est connecté », une erreur signifie « on n'a
  /// pas pu le savoir ». Confondre les deux ferait passer une panne réseau pour
  /// une déconnexion.
  func currentUser() async throws(AuthError) -> AuthenticatedUser?
  func signOut() async
}
