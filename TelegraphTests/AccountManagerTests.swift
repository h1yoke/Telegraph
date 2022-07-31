import XCTest
@testable import Telegraph

class AccountManagerTests: XCTestCase {
    var sut: AccountManager!

    private func generateAccounts(size: Int) -> [Telegraph.Account] {
        var result = [Telegraph.Account]()
        for _ in 0..<size {
            result.append(Telegraph.Account.random())
        }
        return result
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = AccountManager()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testAddDelete() throws {
        let accounts = generateAccounts(size: 1_000)

        accounts.forEach {
            XCTAssert(sut.add(account: $0), "Account \($0) can't be added")
        }

        while sut.count != 0 {
            sut.delete(by: 0)
        }
    }
}
