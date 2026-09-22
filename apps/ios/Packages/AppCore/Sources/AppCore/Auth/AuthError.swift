import Foundation

/// Erreurs telles que l'utilisateur doit les comprendre. Les codes HTTP ne
/// franchissent jamais cette frontière : « 401 » n'apprend rien à personne.
public enum AuthError: Error, Equatable, Sendable, CaseIterable {
  case invalidCredentials
  case rateLimited
  case server
  case unreachable

  public var message: String {
    switch self {
    case .invalidCredentials:
      return "Adresse e-mail ou mot de passe incorrect."
    case .rateLimited:
      return "Trop de tentatives. Réessayez dans une minute."
    case .server:
      return "Le service est momentanément indisponible."
    case .unreachable:
      return "Connexion au serveur impossible. Vérifiez votre réseau."
    }
  }

  public static func from(statusCode: Int) -> AuthError {
    switch statusCode {
    case 401, 403:
      return .invalidCredentials
    case 429:
      return .rateLimited
    default:
      return .server
    }
  }
}
