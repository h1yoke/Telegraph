import XCTest
@testable import Telegraph

class TelegraphAPITests: XCTestCase {
    /// Telegraph API default token
    private var sandboxToken: String!

    /// Tests Telegraph API method with given specs.
    /// - parameter method: Telegraph API method to be queried.
    /// - parameter promise: `XCTest` testing value.
    /// - parameter timeout: Time limit for query.
    /// - parameter completion: Complition closure that decides test outcome.
    private func testMethod<T: TelegraphTypes>(
        method: Telegraph.Method,
        promise: XCTestExpectation,
        timeout: TimeInterval,
        completion: @escaping (Telegraph.Response<T>) -> Void) {
        do {
            try Telegraph.query(method: method, completion: completion)
        } catch let error {
            XCTFail("Unexpected Error: \(error.localizedDescription)")
        }

        wait(for: [promise], timeout: timeout)
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        // sandbox token may be changed =(
        sandboxToken = "d3b25feccb89e508a9114afb82aa421fe2a9712b963b387cc5ad71e58722"
    }

    override func tearDownWithError() throws {
        sandboxToken = nil
        try super.tearDownWithError()
    }

    /// Tests `createAccount` query.
    func testCreateAccount() {
        let promise = expectation(description: "Account is created")
        testMethod(
            method: Telegraph.Method.createAccount(shortName: "test"),
            promise: promise,
            timeout: 30,
            completion: { (response: Telegraph.Response<Telegraph.Account>) in
                if response.ok { promise.fulfill() }
            }
        )
    }

    /// Tests `editAccountInfo` query.
    func testEditAccount() {
        let promise = expectation(description: "Account is edited")
        testMethod(
            method: Telegraph.Method.editAccountInfo(accessToken: sandboxToken, shortName: "Sandbox"),
            promise: promise,
            timeout: 30,
            completion: { (response: Telegraph.Response<Telegraph.Account>) in
                if response.ok { promise.fulfill() }
            }
        )
    }

    /// Tests `getAccount` query.
    func testGetAccount() {
        let promise = expectation(description: "Account info is loaded")
        testMethod(
            method: Telegraph.Method.getAccountInfo(accessToken: sandboxToken),
            promise: promise,
            timeout: 30,
            completion: { (response: Telegraph.Response<Telegraph.Account>) in
                if response.ok { promise.fulfill() }
            }
        )
    }

    /// Tests `revokeAccessToken` query.
    func testRevokeToken() {
        let promise = expectation(description: "Sandbox token revocation is denied")
        testMethod(
            method: Telegraph.Method.revokeAccessToken(accessToken: sandboxToken),
            promise: promise,
            timeout: 30,
            completion: { (response: Telegraph.Response<Telegraph.Account>) in
                if !response.ok, let error = response.error {
                    if error == "SANDBOX_TOKEN_REVOKE_DENIED" || error == "ACCESS_TOKEN_INVALID" {
                        promise.fulfill()
                    }
                }
            }
        )
    }

    /// Tests `createPage` query.
    func testCreatePage() {
        let promise = expectation(description: "Page is created")
        testMethod(
            method: Telegraph.Method.createPage(
                accessToken: sandboxToken,
                title: "test",
                content: [Telegraph.Node(textNode: "test", object: nil)]),
            promise: promise,
            timeout: 30,
            completion: { (response: Telegraph.Response<Telegraph.Page>) in
                if response.ok { promise.fulfill() }
            }
        )
    }

    /// Tests `getPageList` query.
    func testPageList() {
        let promise = expectation(description: "Page list is retrieved")
        testMethod(
            method: Telegraph.Method.getPageList(accessToken: sandboxToken),
            promise: promise,
            timeout: 30,
            completion: { (response: Telegraph.Response<Telegraph.PageList>) in
                if response.ok { promise.fulfill() }
            }
        )
    }
}
