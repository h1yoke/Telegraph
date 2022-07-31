import XCTest
@testable import Telegraph

class TelegraphAPITests: XCTestCase {
    var sandboxToken: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sandboxToken = "b968da509bb76866c35425099bc0989a5ec3b32997d55286c657e6994bbb"
    }

    override func tearDownWithError() throws {
        sandboxToken = nil
        try super.tearDownWithError()
    }

    // Asynchronous test: success fast, failure slow
    func testValidQuery() {
        // given
        let method = Telegraph.Method.revokeAccessToken(accessToken: sandboxToken)
        let promise = expectation(description: "Sandbox token revocation is denied")

        // when
        do {
            try Telegraph.query(method: method, completion: { (response: Telegraph.Response<Telegraph.Account>) in
                if !response.ok, let error = response.error {
                    if error == "SANDBOX_TOKEN_REVOKE_DENIED" {
                        promise.fulfill()
                        return
                    }
                    XCTFail("Unexpected API Error: \(error)")
                    return
                } else if let result = response.result {
                    XCTFail("Unexpected API Result: \(result)")
                    return
                }
            })
        } catch let error {
            XCTFail("Unexpected Error: \(error.localizedDescription)")
        }

        // then
        wait(for: [promise], timeout: 5)
    }
}
