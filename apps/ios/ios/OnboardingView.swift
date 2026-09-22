import AppCore
import DesignTokens
import SwiftUI

struct OnboardingView: View {
  let onFinish: () -> Void

  @State private var state = OnboardingState()

  var body: some View {
    ZStack {
      Color.backgroundPrimary
        .ignoresSafeArea()

      VStack(spacing: Spacing.xl) {
        TabView(selection: pageSelection) {
          ForEach(Array(OnboardingPage.all.enumerated()), id: \.offset) { index, page in
            pageContent(page)
              .tag(index)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))

        Button(action: advance) {
          Text(state.callToAction)
            .font(.buttonLabel)
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.actionPrimary)
            .clipShape(.rect(cornerRadius: Radius.md))
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xl)
      }
    }
  }

  private var pageSelection: Binding<Int> {
    Binding(get: { state.currentIndex }, set: { state.goTo(index: $0) })
  }

  private func pageContent(_ page: OnboardingPage) -> some View {
    VStack(spacing: Spacing.md) {
      Spacer()
      Text(page.title)
        .font(.sectionTitle)
        .foregroundStyle(Color.textPrimary)
        .multilineTextAlignment(.center)
      Text(page.message)
        .font(.bodyText)
        .foregroundStyle(Color.textSecondary)
        .multilineTextAlignment(.center)
      Spacer()
    }
    .padding(.horizontal, Spacing.lg)
  }

  private func advance() {
    if state.isOnLastPage {
      onFinish()
    } else {
      withAnimation { state.advance() }
    }
  }
}

#Preview {
  OnboardingView(onFinish: {})
}
