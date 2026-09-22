import Foundation
import Testing

@testable import AppCore

/// Tests d'intégration contre l'API réelle. Désactivés par défaut : ils
/// dépendent d'un serveur et d'une base qui tournent, et les rendre
/// obligatoires rendrait le CI instable pour de mauvaises raisons.
///
///     docker compose up -d db && pnpm --filter api start:dev
///     INTEGRATION=1 swift test --package-path apps/ios/Packages/AppCore
private let isEnabled = ProcessInfo.processInfo.environment["INTEGRATION"] != nil

@Suite("HTTPAuthClient contre l'API", .enabled(if: isEnabled))
struct HTTPAuthClientIntegrationTests {
  private let client = HTTPAuthClient(
    baseURL: URL(string: "http://localhost:3001")!,
    session: URLSession(configuration: .ephemeral)
  )

  @Test("signs in with the seeded account")
  func signsIn() async throws {
    let user = try await client.signIn(email: "viewer@netflix.test", password: "motdepasse8")

    #expect(user.email == "viewer@netflix.test")
  }

  @Test("a wrong password comes back as invalid credentials, not as a server error")
  func wrongPassword() async {
    await #expect(throws: AuthError.invalidCredentials) {
      try await client.signIn(email: "viewer@netflix.test", password: "mauvaismotdepasse")
    }
  }

  @Test("the session cookie survives the call and is replayed")
  func sessionIsKept() async throws {
    let scoped = HTTPAuthClient(
      baseURL: URL(string: "http://localhost:3001")!,
      session: URLSession(configuration: .ephemeral)
    )

    #expect(try await scoped.currentUser() == nil)
    _ = try await scoped.signIn(email: "viewer@netflix.test", password: "motdepasse8")
    #expect(try await scoped.currentUser() != nil)

    await scoped.signOut()
    #expect(try await scoped.currentUser() == nil)
  }

  @Test("an unreachable server is distinct from bad credentials")
  func unreachable() async {
    let offline = HTTPAuthClient(baseURL: URL(string: "http://localhost:1")!)

    await #expect(throws: AuthError.unreachable) {
      try await offline.signIn(email: "viewer@netflix.test", password: "motdepasse8")
    }
  }

  @Test("the profiles endpoint is refused without a session and served with one")
  func profilesRequireASession() async throws {
    let configuration = URLSessionConfiguration.ephemeral
    let anonymous = HTTPProfileClient(
      baseURL: URL(string: "http://localhost:3001")!,
      session: URLSession(configuration: configuration)
    )

    await #expect(throws: AuthError.invalidCredentials) {
      try await anonymous.profiles()
    }

    let session = URLSession(configuration: .ephemeral)
    let auth = HTTPAuthClient(baseURL: URL(string: "http://localhost:3001")!, session: session)
    _ = try await auth.signIn(email: "viewer@netflix.test", password: "motdepasse8")

    let signedIn = HTTPProfileClient(
      baseURL: URL(string: "http://localhost:3001")!,
      session: session
    )
    let profiles = try await signedIn.profiles()

    #expect(profiles.count == 4)
    #expect(profiles.map(\.position) == [0, 1, 2, 3])
    #expect(profiles.last?.isKids == true)
  }
}
