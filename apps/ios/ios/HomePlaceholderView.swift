import DesignTokens
import SwiftUI

/// Accueil provisoire : matérialise la fin du parcours d'onboarding en
/// attendant l'écran d'accueil réel.
struct HomePlaceholderView: View {
  var body: some View {
    ZStack {
      Color.backgroundPrimary
        .ignoresSafeArea()

      VStack(spacing: Spacing.sm) {
        Text("Accueil")
          .font(.screenTitle)
          .foregroundStyle(Color.textPrimary)
        Text("À construire")
          .font(.metadata)
          .foregroundStyle(Color.textSecondary)
      }
    }
  }
}

#Preview {
  HomePlaceholderView()
}
