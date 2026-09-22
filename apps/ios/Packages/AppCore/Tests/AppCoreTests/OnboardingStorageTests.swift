import Foundation
import Testing

@testable import AppCore

@Suite("OnboardingStorage")
struct OnboardingStorageTests {
  @Test("a fresh install has not completed the onboarding")
  func freshInstall() {
    let storage = InMemoryOnboardingStorage()

    #expect(storage.hasCompletedOnboarding == false)
  }

  @Test("completing the onboarding is remembered")
  func remembersCompletion() {
    let storage = InMemoryOnboardingStorage()

    storage.markOnboardingCompleted()

    #expect(storage.hasCompletedOnboarding == true)
  }

  @Test("resetting brings the onboarding back")
  func reset() {
    let storage = InMemoryOnboardingStorage()
    storage.markOnboardingCompleted()

    storage.resetOnboarding()

    #expect(storage.hasCompletedOnboarding == false)
  }

  @Test("the UserDefaults implementation round-trips through its own suite")
  func userDefaultsRoundTrip() throws {
    let suiteName = "OnboardingStorageTests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }
    let storage = UserDefaultsOnboardingStorage(defaults: defaults)

    #expect(storage.hasCompletedOnboarding == false)
    storage.markOnboardingCompleted()
    #expect(storage.hasCompletedOnboarding == true)
  }
}
