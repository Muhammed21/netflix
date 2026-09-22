import DesignTokens
import SwiftUI

/// Bouton rouge pleine largeur. Désactivé tant que la saisie est invalide, et
/// remplacé par un indicateur pendant l'appel réseau — l'utilisateur ne doit
/// jamais se demander si son tap a été pris en compte.
struct AuthPrimaryButton: View {
  let title: String
  let isEnabled: Bool
  let isLoading: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      ZStack {
        Text(title)
          .font(.buttonLabel)
          .opacity(isLoading ? 0 : 1)

        if isLoading {
          ProgressView().tint(Color.textPrimary)
        }
      }
      .foregroundStyle(Color.textPrimary)
      .frame(maxWidth: .infinity)
      .frame(height: 56)
      .background(Color.actionPrimary.opacity(isEnabled ? 1 : 0.4))
      .clipShape(.rect(cornerRadius: Radius.sm))
    }
    .disabled(isEnabled == false || isLoading)
  }
}
