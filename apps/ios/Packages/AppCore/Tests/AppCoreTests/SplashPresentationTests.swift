import Testing

@testable import AppCore

@Suite("SplashPresentation")
struct SplashPresentationTests {
  @Test("plays the video when nothing prevents it")
  func nominal() {
    let presentation = splashPresentation(isReduceMotionEnabled: false, isVideoAvailable: true)

    #expect(presentation == .video)
  }

  @Test("falls back to the static wordmark when Reduce Motion is on")
  func reduceMotion() {
    let presentation = splashPresentation(isReduceMotionEnabled: true, isVideoAvailable: true)

    #expect(presentation == .staticWordmark(duration: SplashPresentation.fallbackDuration))
  }

  @Test("falls back to the static wordmark when the asset is missing")
  func missingAsset() {
    let presentation = splashPresentation(isReduceMotionEnabled: false, isVideoAvailable: false)

    #expect(presentation == .staticWordmark(duration: SplashPresentation.fallbackDuration))
  }

  @Test("falls back only once when both reasons apply")
  func bothReasons() {
    let presentation = splashPresentation(isReduceMotionEnabled: true, isVideoAvailable: false)

    #expect(presentation == .staticWordmark(duration: SplashPresentation.fallbackDuration))
  }

  @Test("the fallback never hangs on a zero or negative duration")
  func fallbackDurationIsUsable() {
    #expect(SplashPresentation.fallbackDuration > .zero)
  }
}
