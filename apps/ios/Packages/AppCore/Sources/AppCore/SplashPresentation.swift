import Foundation

/// Comment le splash doit se rendre. Le repli n'est pas décoratif : sans lui,
/// un asset introuvable laisserait un écran noir définitif au démarrage.
public enum SplashPresentation: Equatable, Sendable {
  case video
  case staticWordmark(duration: Duration)

  /// Durée d'affichage du mot-clé statique quand la vidéo n'est pas jouée.
  /// Proche de celle de l'animation (2,08 s) pour que le démarrage garde le
  /// même rythme dans les deux branches.
  public static let fallbackDuration: Duration = .milliseconds(1200)
}

public func splashPresentation(
  isReduceMotionEnabled: Bool,
  isVideoAvailable: Bool
) -> SplashPresentation {
  guard isVideoAvailable, isReduceMotionEnabled == false else {
    return .staticWordmark(duration: SplashPresentation.fallbackDuration)
  }

  return .video
}
