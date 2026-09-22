import AppCore
import DesignTokens
import SwiftUI

struct SignInView: View {
  let client: AuthClient
  let onSignedIn: (AuthenticatedUser) -> Void

  @State private var flow = SignInFlow()
  @State private var errorMessage: String?
  @State private var isSubmitting = false
  @FocusState private var isFieldFocused: Bool

  var body: some View {
    ZStack(alignment: .top) {
      // Dégradé mesuré sur la maquette : marron sombre en haut, noir en bas.
      LinearGradient(
        colors: [Color.backgroundAuthGradientStart, Color.backgroundAuthGradientEnd],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()

      VStack(alignment: .leading, spacing: Spacing.lg) {
        Image(.wordmark)
          .resizable()
          .scaledToFit()
          .frame(height: 28)
          .padding(.bottom, Spacing.xl)

        Text(title)
          .font(.screenTitle)
          .foregroundStyle(Color.textPrimary)
          .fixedSize(horizontal: false, vertical: true)

        field
          .padding(.top, Spacing.sm)

        if let errorMessage {
          Text(errorMessage)
            .font(.metadata)
            .foregroundStyle(Color.actionPrimary)
            .transition(.opacity)
        }

        AuthPrimaryButton(
          title: flow.step == .email ? "Continuer" : "Se connecter",
          isEnabled: flow.canContinue,
          isLoading: isSubmitting,
          action: submit
        )

        Button(action: showHelp) {
          HStack(spacing: Spacing.xs) {
            Text("Besoin d'aide")
            Image(systemName: "chevron.down")
          }
          .font(.bodyText)
          .foregroundStyle(Color.textPrimary)
        }
        .padding(.top, Spacing.md)

        Spacer()
      }
      .padding(.horizontal, Spacing.lg)
      .padding(.top, Spacing.md)
    }
    .task { isFieldFocused = true }
    .onChange(of: flow.step) { isFieldFocused = true }
    .task { isFieldFocused = true }
    .onChange(of: flow.step) { isFieldFocused = true }
    .animation(.easeInOut(duration: 0.25), value: flow.step)
    .animation(.easeInOut(duration: 0.2), value: errorMessage)
  }

  private var title: String {
    flow.step == .email
      ? "Saisissez vos informations"
      : "Saisissez votre mot de passe"
  }

  @ViewBuilder
  private var field: some View {
    switch flow.step {
    case .email:
      AuthTextField(placeholder: "Adresse e-mail ou numéro de mobile", text: $flow.email)
        .textContentType(.username)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .focused($isFieldFocused)
    case .password:
      AuthTextField(placeholder: "Mot de passe", text: $flow.password, isSecure: true)
        .textContentType(.password)
        .focused($isFieldFocused)
    }
  }

  private func submit() {
    errorMessage = nil

    guard flow.step == .password else {
      flow.advance()
      return
    }

    isSubmitting = true
    Task {
      defer { isSubmitting = false }
      do {
        let user = try await client.signIn(email: flow.email, password: flow.password)
        onSignedIn(user)
      } catch let error as AuthError {
        errorMessage = error.message
      } catch {
        errorMessage = AuthError.server.message
      }
    }
  }

  private func showHelp() {
    // Écran d'aide non implémenté : revenir à l'adresse est l'action utile à ce
    // stade, plutôt qu'un bouton qui ne fait rien.
    guard flow.step == .password else { return }
    errorMessage = nil
    flow.goBackToEmail()
  }
}

#Preview("Étape e-mail") {
  SignInView(client: InMemoryAuthClient(), onSignedIn: { _ in })
}
