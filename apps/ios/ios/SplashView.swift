import AppCore
import AppUI
import DesignTokens
import SwiftUI

/// Prend le relais du launch screen natif : même fond noir, donc aucune rupture
/// visuelle. Deux rendus possibles, décidés par `splashPresentation` — la vidéo
/// de marque, ou le mot-clé statique en repli.
struct SplashView: View {
  let onFinished: () -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  var body: some View {
    ZStack {
      Color.backgroundPrimary
        .ignoresSafeArea()

      switch presentation {
      case .video:
        // Le fond de la vidéo a été normalisé en noir pur à la préparation de
        // l'asset : aucune couture avec Color.backgroundPrimary.
        if let url = SplashAsset.videoURL {
          VideoPlayerView(url: url, mode: .once, onFinished: onFinished)
            .aspectRatio(720 / 400, contentMode: .fit)
            .padding(.horizontal, Spacing.lg)
        }

      case .staticWordmark(let duration):
        StaticWordmark(duration: duration, onFinished: onFinished)
      }
    }
  }

  private var presentation: SplashPresentation {
    splashPresentation(
      isReduceMotionEnabled: reduceMotion,
      isVideoAvailable: SplashAsset.isAvailable
    )
  }
}

private struct StaticWordmark: View {
  let duration: Duration
  let onFinished: () -> Void

  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isVisible = false

  var body: some View {
    Text("NETFLIX")
      .font(.screenTitle)
      .tracking(4)
      .foregroundStyle(Color.actionPrimary)
      .opacity(isVisible ? 1 : 0)
      .onAppear {
        // Pas d'animation d'apparition si l'utilisateur les a réduites.
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.6)) { isVisible = true }
      }
      .task {
        try? await Task.sleep(for: duration)
        onFinished()
      }
  }
}

#Preview("Vidéo") {
  SplashView(onFinished: {})
}
