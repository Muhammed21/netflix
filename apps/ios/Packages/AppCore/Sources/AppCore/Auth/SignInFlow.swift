import Foundation

/// Parcours en deux temps, comme la maquette : l'adresse d'abord, le mot de
/// passe ensuite. Valeur pure, donc testable sans réseau ni interface.
public struct SignInFlow: Equatable, Sendable {
  public enum Step: Equatable, Sendable {
    case email
    case password
  }

  public private(set) var step: Step = .email
  public var email: String = ""
  public var password: String = ""

  public init() {}

  public var canContinue: Bool {
    switch step {
    case .email:
      return SignInCredentials.isValidEmail(email)
    case .password:
      return password.isEmpty == false
    }
  }

  public mutating func advance() {
    guard step == .email, canContinue else { return }
    step = .password
  }

  /// Revenir en arrière efface le mot de passe : le conserver en mémoire alors
  /// que l'utilisateur change de compte n'a aucun sens et le ferait fuiter dans
  /// le champ suivant.
  public mutating func goBackToEmail() {
    step = .email
    password = ""
  }
}
