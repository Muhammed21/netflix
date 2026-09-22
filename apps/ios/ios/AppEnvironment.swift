import AppCore
import Foundation

/// Point unique de configuration de l'app. L'URL de l'API vient de l'Info.plist,
/// alimentée par une build setting : la coder en dur obligerait à recompiler
/// pour changer de serveur.
enum AppEnvironment {
  static var apiBaseURL: URL {
    let configured = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String
    return URL(string: configured ?? "") ?? URL(string: "http://localhost:3001")!
  }

  static let authClient: AuthClient = HTTPAuthClient(baseURL: apiBaseURL)
}
