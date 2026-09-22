import DesignTokens
import SwiftUI

/// Affiché quand l'app n'a pas pu déterminer l'état de la session au démarrage.
struct StartupFailureView: View {
  let message: String
  let onRetry: () -> Void

  var body: some View {
    ZStack {
      Color.backgroundPrimary
        .ignoresSafeArea()

      VStack(spacing: Spacing.md) {
        Text(message)
          .font(.bodyText)
          .foregroundStyle(Color.textSecondary)
          .multilineTextAlignment(.center)

        Button("Réessayer", action: onRetry)
          .font(.buttonLabel)
          .foregroundStyle(Color.actionPrimary)
      }
      .padding(.horizontal, Spacing.xl)
    }
  }
}

#Preview {
  StartupFailureView(message: "Connexion au serveur impossible.", onRetry: {})
}
