import DesignTokens
import SwiftUI

/// Champ de saisie de l'écran de connexion : surface, bordure et hauteur
/// relevées sur la maquette, toutes issues des tokens.
struct AuthTextField: View {
  let placeholder: String
  @Binding var text: String
  var isSecure: Bool = false

  var body: some View {
    Group {
      if isSecure {
        SecureField("", text: $text, prompt: prompt)
      } else {
        TextField("", text: $text, prompt: prompt)
      }
    }
    .font(.bodyText)
    .foregroundStyle(Color.textPrimary)
    .padding(.horizontal, Spacing.md)
    .frame(height: 56)
    .background(Color.surfaceField)
    .clipShape(.rect(cornerRadius: Radius.sm))
    .overlay {
      RoundedRectangle(cornerRadius: Radius.sm)
        .stroke(Color.borderField, lineWidth: 1)
    }
  }

  private var prompt: Text {
    Text(placeholder).foregroundStyle(Color.textSecondary)
  }
}
