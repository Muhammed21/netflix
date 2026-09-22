import Foundation

/// Client de l'API d'authentification.
///
/// Aucune gestion de jeton n'est écrite ici : better-auth pose un cookie
/// `httpOnly`, qu'`URLSession` range dans `HTTPCookieStorage` et renvoie
/// automatiquement. Ce stockage persiste entre les lancements dans le conteneur
/// de l'app, ce qui suffit à garder la session.
public struct HTTPAuthClient: AuthClient {
  private struct SessionResponse: Decodable {
    let user: AuthenticatedUser
  }

  private let baseURL: URL
  private let session: URLSession

  public init(baseURL: URL, session: URLSession = .shared) {
    self.baseURL = baseURL
    self.session = session
  }

  public func signIn(
    email: String,
    password: String
  ) async throws(AuthError) -> AuthenticatedUser {
    var request = URLRequest(url: baseURL.appending(path: "auth/sign-in/email"))
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONEncoder().encode([
      "email": SignInCredentials.normalise(email),
      "password": password,
    ])

    let data: Data
    let response: URLResponse
    do {
      (data, response) = try await session.data(for: request)
    } catch {
      throw AuthError.unreachable
    }

    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
    guard (200..<300).contains(status) else {
      throw AuthError.from(statusCode: status)
    }

    guard let decoded = try? JSONDecoder().decode(SessionResponse.self, from: data) else {
      throw AuthError.server
    }

    return decoded.user
  }

  /// L'absence de session est un cas nominal et renvoie `nil` ; une panne de
  /// transport lève, pour que l'appelant ne la confonde pas avec une
  /// déconnexion.
  public func currentUser() async throws(AuthError) -> AuthenticatedUser? {
    let request = URLRequest(url: baseURL.appending(path: "auth/session"))

    let data: Data
    let response: URLResponse
    do {
      (data, response) = try await session.data(for: request)
    } catch {
      throw AuthError.unreachable
    }

    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
    guard (200..<300).contains(status) else {
      // L'API répond 200 avec un corps vide quand il n'y a pas de session ;
      // un 401 signifie tout autant « pas de session ».
      if status == 401 || status == 403 { return nil }
      throw AuthError.from(statusCode: status)
    }

    return try? JSONDecoder().decode(SessionResponse.self, from: data).user
  }

  public func signOut() async {
    var request = URLRequest(url: baseURL.appending(path: "auth/sign-out"))
    request.httpMethod = "POST"
    _ = try? await session.data(for: request)
  }
}

/// Double en mémoire, pour les tests et les previews SwiftUI.
public actor InMemoryAuthClient: AuthClient {
  private var user: AuthenticatedUser?
  private let expectedPassword: String
  private let failure: AuthError?

  public init(
    signedInAs user: AuthenticatedUser? = nil,
    expectedPassword: String = "motdepasse8",
    failure: AuthError? = nil
  ) {
    self.user = user
    self.expectedPassword = expectedPassword
    self.failure = failure
  }

  public func signIn(
    email: String,
    password: String
  ) async throws(AuthError) -> AuthenticatedUser {
    if let failure { throw failure }
    guard password == expectedPassword else { throw AuthError.invalidCredentials }

    let signedIn = AuthenticatedUser(
      id: "test",
      email: SignInCredentials.normalise(email),
      name: "Test"
    )
    user = signedIn
    return signedIn
  }

  public func currentUser() async throws(AuthError) -> AuthenticatedUser? {
    if let failure { throw failure }
    return user
  }

  public func signOut() async { user = nil }
}
