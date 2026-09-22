import Foundation

/// Visuel d'avatar. Les valeurs correspondent à l'énumération `AvatarStyle` de
/// l'API et aux images embarquées par l'app.
public enum ProfileAvatar: String, Codable, Sendable, CaseIterable {
  case blue = "BLUE"
  case yellow = "YELLOW"
  case red = "RED"
  case kids = "KIDS"

  /// Un avatar ajouté côté serveur ne doit pas casser une version déjà
  /// installée : on retombe sur un visuel connu plutôt que de faire échouer
  /// toute la réponse.
  public init(from decoder: Decoder) throws {
    let raw = try decoder.singleValueContainer().decode(String.self)
    self = ProfileAvatar(rawValue: raw) ?? .blue
  }
}

public struct Profile: Equatable, Sendable, Codable, Identifiable {
  public let id: String
  public let name: String
  public let avatar: ProfileAvatar
  public let isKids: Bool
  public let position: Int

  public init(id: String, name: String, avatar: ProfileAvatar, isKids: Bool, position: Int) {
    self.id = id
    self.name = name
    self.avatar = avatar
    self.isKids = isKids
    self.position = position
  }
}
