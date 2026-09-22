import Foundation
import Testing

@testable import AppCore

@Suite("AuthClient contract")
struct AuthClientTests {
  @Test("a fresh client has nobody signed in")
  func noSessionInitially() async throws {
    let client = InMemoryAuthClient()

    #expect(try await client.currentUser() == nil)
  }

  @Test("signing in with the right password returns the user")
  func signInSucceeds() async throws {
    let client = InMemoryAuthClient(expectedPassword: "motdepasse8")

    let user = try await client.signIn(email: "Viewer@Netflix.TEST", password: "motdepasse8")

    #expect(user.email == "viewer@netflix.test")
  }

  @Test("the session survives the call, so a relaunch finds it")
  func sessionPersists() async throws {
    let client = InMemoryAuthClient()
    _ = try await client.signIn(email: "viewer@netflix.test", password: "motdepasse8")

    #expect(try await client.currentUser() != nil)
  }

  @Test("a wrong password surfaces as invalid credentials")
  func wrongPassword() async {
    let client = InMemoryAuthClient(expectedPassword: "motdepasse8")

    await #expect(throws: AuthError.invalidCredentials) {
      try await client.signIn(email: "viewer@netflix.test", password: "mauvais")
    }
  }

  @Test("a transport failure surfaces as unreachable, not as bad credentials")
  func unreachable() async {
    let client = InMemoryAuthClient(failure: .unreachable)

    await #expect(throws: AuthError.unreachable) {
      try await client.signIn(email: "viewer@netflix.test", password: "motdepasse8")
    }
  }

  @Test("signing out clears the session")
  func signOut() async throws {
    let client = InMemoryAuthClient()
    _ = try await client.signIn(email: "viewer@netflix.test", password: "motdepasse8")

    await client.signOut()

    #expect(try await client.currentUser() == nil)
  }
}

@Suite("Session resolution")
struct SessionResolutionTests {
  /// Distinguer « pas de session » d'« impossible de savoir » : sans ça, une
  /// panne réseau au démarrage déconnecterait visuellement un utilisateur qui
  /// est en réalité toujours connecté.
  @Test("no session resolves to nil, not to an error")
  func noSession() async throws {
    let client = InMemoryAuthClient()

    #expect(try await client.currentUser() == nil)
  }

  @Test("an unreachable server throws instead of pretending nobody is signed in")
  func unreachableDoesNotLookLikeSignedOut() async {
    let client = InMemoryAuthClient(failure: .unreachable)

    await #expect(throws: AuthError.unreachable) {
      try await client.currentUser()
    }
  }
}
