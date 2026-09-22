import Foundation
import Testing

@testable import AppCore

@Suite("SignInCredentials")
struct SignInCredentialsTests {
  @Test("accepts a well-formed email")
  func acceptsEmail() {
    #expect(SignInCredentials.isValidEmail("viewer@netflix.test"))
  }

  @Test(
    "rejects malformed emails",
    arguments: ["", "  ", "viewer", "viewer@", "@netflix.test", "viewer@netflix", "a b@c.de"]
  )
  func rejectsEmail(_ candidate: String) {
    #expect(SignInCredentials.isValidEmail(candidate) == false)
  }

  @Test("ignores surrounding whitespace, which keyboards add readily")
  func trimsWhitespace() {
    #expect(SignInCredentials.isValidEmail("  viewer@netflix.test  "))
  }

  @Test("normalises the email before it reaches the API")
  func normalises() {
    #expect(SignInCredentials.normalise("  Viewer@Netflix.TEST ") == "viewer@netflix.test")
  }
}

@Suite("SignInStep")
struct SignInStepTests {
  @Test("starts on the email step")
  func startsOnEmail() {
    #expect(SignInFlow().step == .email)
  }

  @Test("cannot continue while the email is invalid")
  func blocksInvalidEmail() {
    var flow = SignInFlow()
    flow.email = "viewer"

    #expect(flow.canContinue == false)
    flow.advance()
    #expect(flow.step == .email)
  }

  @Test("moves to the password step once the email is valid")
  func advances() {
    var flow = SignInFlow()
    flow.email = "viewer@netflix.test"

    #expect(flow.canContinue)
    flow.advance()
    #expect(flow.step == .password)
  }

  @Test("cannot submit an empty password")
  func blocksEmptyPassword() {
    var flow = SignInFlow()
    flow.email = "viewer@netflix.test"
    flow.advance()

    #expect(flow.canContinue == false)
    flow.password = "motdepasse8"
    #expect(flow.canContinue)
  }

  @Test("going back to the email step clears the password")
  func backClearsPassword() {
    var flow = SignInFlow()
    flow.email = "viewer@netflix.test"
    flow.advance()
    flow.password = "motdepasse8"

    flow.goBackToEmail()

    #expect(flow.step == .email)
    #expect(flow.password.isEmpty)
  }
}

@Suite("AuthError")
struct AuthErrorTests {
  @Test("maps 401 to a credentials message, never a technical one")
  func unauthorised() {
    let error = AuthError.from(statusCode: 401)

    #expect(error == .invalidCredentials)
    #expect(error.message.contains("401") == false)
  }

  @Test("maps 429 to its own message so the user knows to wait")
  func rateLimited() {
    #expect(AuthError.from(statusCode: 429) == .rateLimited)
  }

  @Test("maps other server codes to a server message")
  func serverError() {
    #expect(AuthError.from(statusCode: 500) == .server)
  }

  @Test("a transport failure is distinct from bad credentials")
  func unreachable() {
    #expect(AuthError.unreachable.message != AuthError.invalidCredentials.message)
  }

  @Test("every case carries a non-empty, human message")
  func allMessagesAreUsable() {
    for error in AuthError.allCases {
      #expect(error.message.isEmpty == false)
    }
  }
}
