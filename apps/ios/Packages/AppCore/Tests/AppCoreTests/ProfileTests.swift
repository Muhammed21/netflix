import Foundation
import Testing

@testable import AppCore

@Suite("Profile decoding")
struct ProfileDecodingTests {
  private func decode(_ json: String) throws -> [Profile] {
    try JSONDecoder().decode([Profile].self, from: Data(json.utf8))
  }

  @Test("decodes the payload the API actually returns")
  func decodesPayload() throws {
    let profiles = try decode(
      """
      [{"id":"p1","name":"Profil 1","avatar":"BLUE","isKids":false,"position":0}]
      """
    )

    #expect(profiles.count == 1)
    #expect(profiles[0].name == "Profil 1")
    #expect(profiles[0].avatar == .blue)
    #expect(profiles[0].isKids == false)
  }

  @Test("decodes every avatar the API can send", arguments: [
    ("BLUE", ProfileAvatar.blue),
    ("YELLOW", ProfileAvatar.yellow),
    ("RED", ProfileAvatar.red),
    ("KIDS", ProfileAvatar.kids),
  ])
  func decodesAvatars(_ raw: String, _ expected: ProfileAvatar) throws {
    let profiles = try decode(
      """
      [{"id":"p1","name":"X","avatar":"\(raw)","isKids":false,"position":0}]
      """
    )

    #expect(profiles[0].avatar == expected)
  }

  /// Un avatar ajouté côté serveur ne doit pas casser une version déjà
  /// installée de l'app : on retombe sur un visuel neutre plutôt que d'échouer.
  @Test("an unknown avatar falls back instead of failing the whole response")
  func unknownAvatarFallsBack() throws {
    let profiles = try decode(
      """
      [{"id":"p1","name":"X","avatar":"PURPLE","isKids":false,"position":0}]
      """
    )

    #expect(profiles[0].avatar == .blue)
  }

  @Test("an empty list decodes to an empty list")
  func emptyList() throws {
    #expect(try decode("[]").isEmpty)
  }
}

@Suite("ProfileClient contract")
struct ProfileClientTests {
  @Test("returns the profiles it holds")
  func returnsProfiles() async throws {
    let client = InMemoryProfileClient(profiles: [
      Profile(id: "p1", name: "Profil 1", avatar: .blue, isKids: false, position: 0)
    ])

    #expect(try await client.profiles().count == 1)
  }

  @Test("an expired session surfaces as invalid credentials, so the app can sign in again")
  func expiredSession() async {
    let client = InMemoryProfileClient(failure: .invalidCredentials)

    await #expect(throws: AuthError.invalidCredentials) {
      try await client.profiles()
    }
  }

  @Test("an unreachable server is distinct from an expired session")
  func unreachable() async {
    let client = InMemoryProfileClient(failure: .unreachable)

    await #expect(throws: AuthError.unreachable) {
      try await client.profiles()
    }
  }
}
