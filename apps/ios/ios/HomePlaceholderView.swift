import AppCore
import DesignTokens
import SwiftUI

/// Accueil provisoire : matérialise la fin du parcours en attendant l'écran
/// d'accueil réel.
struct HomePlaceholderView: View {
  let profile: Profile

  var body: some View {
    ZStack {
      Color.backgroundPrimary
        .ignoresSafeArea()

      VStack(spacing: Spacing.sm) {
        Text("Accueil")
          .font(.screenTitle)
          .foregroundStyle(Color.textPrimary)
        Text(profile.name)
          .font(.metadata)
          .foregroundStyle(Color.textSecondary)
      }
    }
  }
}

#Preview {
  HomePlaceholderView(
    profile: Profile(id: "1", name: "Profil 1", avatar: .blue, isKids: false, position: 0)
  )
}
