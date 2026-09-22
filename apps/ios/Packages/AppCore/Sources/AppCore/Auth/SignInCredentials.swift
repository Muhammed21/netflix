import Foundation

public enum SignInCredentials {
  /// Normalise avant envoi : les claviers mobiles ajoutent volontiers une
  /// espace finale, et les adresses sont insensibles à la casse côté serveur.
  public static func normalise(_ email: String) -> String {
    email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  }

  /// Validation délibérément permissive : elle sert à éviter un aller-retour
  /// réseau manifestement inutile, pas à décider ce qu'est une adresse valide —
  /// seul le serveur en juge.
  public static func isValidEmail(_ email: String) -> Bool {
    let candidate = normalise(email)
    guard candidate.contains(" ") == false else { return false }

    let parts = candidate.split(separator: "@", omittingEmptySubsequences: false)
    guard parts.count == 2, let local = parts.first, let domain = parts.last else { return false }

    return local.isEmpty == false && domain.contains(".") && domain.hasSuffix(".") == false
      && domain.hasPrefix(".") == false
  }
}
