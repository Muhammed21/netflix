import AppCore
import DesignTokens
import SwiftUI

struct ProfileSelectionView: View {
  let client: ProfileClient
  let onSelect: (Profile) -> Void
  let onSessionExpired: () -> Void

  private enum State: Equatable {
    case loading
    case loaded([Profile])
    case failed(String)
  }

  @SwiftUI.State private var state: State = .loading

  private let columns = [
    GridItem(.flexible(), spacing: Spacing.lg),
    GridItem(.flexible(), spacing: Spacing.lg),
  ]

  var body: some View {
    ZStack {
      Color.backgroundPrimary
        .ignoresSafeArea()

      VStack(spacing: Spacing.xl) {
        Image(.wordmark)
          .resizable()
          .scaledToFit()
          .frame(height: 28)
          .padding(.top, Spacing.md)

        content

        Spacer()
      }
      .padding(.horizontal, Spacing.xl)
    }
    .animation(.easeInOut(duration: 0.25), value: state)
    .task { await load() }
  }

  @ViewBuilder
  private var content: some View {
    switch state {
    case .loading:
      Spacer()
      ProgressView().tint(Color.textPrimary)

    case .loaded(let profiles):
      Text("Qui regarde ?")
        .font(.sectionTitle)
        .foregroundStyle(Color.textPrimary)

      LazyVGrid(columns: columns, spacing: Spacing.lg) {
        ForEach(profiles) { profile in
          Button { onSelect(profile) } label: {
            ProfileTile(profile: profile)
          }
          .buttonStyle(.plain)
        }
      }
      // La maquette pose une grille de 225 pt sur un écran de 375, soit 60 % de
      // la largeur. Sans cette contrainte, les vignettes doublent de taille.
      .frame(maxWidth: 260)

    case .failed(let message):
      Spacer()
      VStack(spacing: Spacing.md) {
        Text(message)
          .font(.bodyText)
          .foregroundStyle(Color.textSecondary)
          .multilineTextAlignment(.center)

        Button("Réessayer") { Task { await load() } }
          .font(.buttonLabel)
          .foregroundStyle(Color.actionPrimary)
      }
    }
  }

  private func load() async {
    state = .loading
    do {
      state = .loaded(try await client.profiles())
    } catch AuthError.invalidCredentials {
      // La session a expiré : renvoyer vers la connexion est la seule issue
      // utile, une grille vide ne dirait rien à l'utilisateur.
      onSessionExpired()
    } catch let error as AuthError {
      state = .failed(error.message)
    } catch {
      state = .failed(AuthError.server.message)
    }
  }
}

private struct ProfileTile: View {
  let profile: Profile

  var body: some View {
    VStack(spacing: Spacing.sm) {
      Image(profile.avatar.imageResource)
        .resizable()
        .scaledToFit()
        .frame(maxWidth: .infinity)
        .aspectRatio(100.0 / 92.0, contentMode: .fit)
        .clipShape(.rect(cornerRadius: Radius.md))

      Text(profile.name)
        .font(.metadata)
        .foregroundStyle(Color.textPrimary)
        .lineLimit(1)
    }
  }
}

extension ProfileAvatar {
  fileprivate var imageResource: ImageResource {
    switch self {
    case .blue: .avatarBlue
    case .yellow: .avatarYellow
    case .red: .avatarRed
    case .kids: .avatarKids
    }
  }
}

#Preview("Profils chargés") {
  ProfileSelectionView(
    client: InMemoryProfileClient(profiles: [
      Profile(id: "1", name: "Profil 1", avatar: .blue, isKids: false, position: 0),
      Profile(id: "2", name: "Profil 2", avatar: .yellow, isKids: false, position: 1),
      Profile(id: "3", name: "Profil 3", avatar: .red, isKids: false, position: 2),
      Profile(id: "4", name: "Enfants", avatar: .kids, isKids: true, position: 3),
    ]),
    onSelect: { _ in },
    onSessionExpired: {}
  )
}

#Preview("Erreur réseau") {
  ProfileSelectionView(
    client: InMemoryProfileClient(failure: .unreachable),
    onSelect: { _ in },
    onSessionExpired: {}
  )
}
