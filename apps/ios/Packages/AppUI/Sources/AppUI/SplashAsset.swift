import Foundation

/// Accès à l'animation du splash embarquée dans le bundle du package.
///
/// L'asset est embarqué et jamais téléchargé : l'URL source fournie par le
/// designer est signée et expire. Aucune requête réseau au lancement.
public enum SplashAsset {
  public static let videoURL: URL? = Bundle.module.url(
    forResource: "splash-wordmark",
    withExtension: "mp4"
  )

  public static var isAvailable: Bool { videoURL != nil }
}
