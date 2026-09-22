import AppCore
import DesignTokens
import SwiftUI

/// Accueil provisoire : matérialise la fin du parcours en attendant l'écran
/// d'accueil réel.
struct HomePlaceholderView: View {
  let user: AuthenticatedUser

  var body: some View {
    ZStack {
      Color.backgroundPrimary
        .ignoresSafeArea()

      VStack(spacing: Spacing.sm) {
        Text("Accueil")
          .font(.screenTitle)
          .foregroundStyle(Color.textPrimary)
        Text(user.email)
          .font(.metadata)
          .foregroundStyle(Color.textSecondary)
      }
    }
  }
}

#Preview {
  HomePlaceholderView(
    user: AuthenticatedUser(id: "1", email: "viewer@netflix.test", name: "Viewer")
  )
}
