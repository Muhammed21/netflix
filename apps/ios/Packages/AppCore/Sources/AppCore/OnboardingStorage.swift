import Foundation

/// Port de persistance. L'app branche l'implémentation UserDefaults ; les tests
/// branchent celle en mémoire, pour ne jamais dépendre de l'état de la machine.
public protocol OnboardingStorage: AnyObject {
  var hasCompletedOnboarding: Bool { get }
  func markOnboardingCompleted()
  func resetOnboarding()
}

public final class UserDefaultsOnboardingStorage: OnboardingStorage {
  private static let key = "onboarding.completed"

  private let defaults: UserDefaults

  public init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  public var hasCompletedOnboarding: Bool {
    defaults.bool(forKey: Self.key)
  }

  public func markOnboardingCompleted() {
    defaults.set(true, forKey: Self.key)
  }

  public func resetOnboarding() {
    defaults.removeObject(forKey: Self.key)
  }
}

public final class InMemoryOnboardingStorage: OnboardingStorage {
  public private(set) var hasCompletedOnboarding: Bool

  public init(hasCompletedOnboarding: Bool = false) {
    self.hasCompletedOnboarding = hasCompletedOnboarding
  }

  public func markOnboardingCompleted() {
    hasCompletedOnboarding = true
  }

  public func resetOnboarding() {
    hasCompletedOnboarding = false
  }
}
