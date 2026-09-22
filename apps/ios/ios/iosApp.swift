import AppCore
import SwiftUI

@main
struct iosApp: App {
  private let storage = UserDefaultsOnboardingStorage()

  var body: some Scene {
    WindowGroup {
      RootView(
        storage: storage,
        client: AppEnvironment.authClient,
        profileClient: AppEnvironment.profileClient
      )
    }
  }
}
