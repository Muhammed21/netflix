import Foundation

/// Lit `GET /profiles`. Le cookie de session est rejoué automatiquement par
/// `URLSession`, comme pour `HTTPAuthClient` — rien à transporter à la main.
public struct HTTPProfileClient: ProfileClient {
  private let baseURL: URL
  private let session: URLSession

  public init(baseURL: URL, session: URLSession = .shared) {
    self.baseURL = baseURL
    self.session = session
  }

  public func profiles() async throws(AuthError) -> [Profile] {
    let request = URLRequest(url: baseURL.appending(path: "profiles"))

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

    guard let decoded = try? JSONDecoder().decode([Profile].self, from: data) else {
      throw AuthError.server
    }

    return decoded
  }
}
