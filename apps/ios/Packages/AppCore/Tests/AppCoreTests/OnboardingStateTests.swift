import Testing

@testable import AppCore

@Suite("OnboardingState")
struct OnboardingStateTests {
  @Test("starts on the first page")
  func startsOnFirstPage() {
    let state = OnboardingState()

    #expect(state.currentIndex == 0)
    #expect(state.currentPage == OnboardingPage.all[0])
  }

  @Test("advances to the next page")
  func advances() {
    var state = OnboardingState()

    state.advance()

    #expect(state.currentIndex == 1)
  }

  @Test("never advances past the last page")
  func stopsAtTheEnd() {
    var state = OnboardingState()

    for _ in 0..<(OnboardingPage.all.count + 5) { state.advance() }

    #expect(state.currentIndex == OnboardingPage.all.count - 1)
  }

  @Test("knows when it reached the last page")
  func detectsLastPage() {
    var state = OnboardingState()
    #expect(state.isOnLastPage == false)

    while state.isOnLastPage == false { state.advance() }

    #expect(state.currentIndex == OnboardingPage.all.count - 1)
  }

  @Test("reports the call to action of the current page")
  func callToAction() {
    var state = OnboardingState()
    #expect(state.callToAction == "Suivant")

    while state.isOnLastPage == false { state.advance() }

    #expect(state.callToAction == "Commencer")
  }

  @Test("ships exactly three pages, each with a title and a description")
  func pagesAreComplete() {
    #expect(OnboardingPage.all.count == 3)

    for page in OnboardingPage.all {
      #expect(page.title.isEmpty == false)
      #expect(page.message.isEmpty == false)
    }
  }
}
