import XCTest
@testable import Telegraph

class PersistanceTests: XCTestCase {
    var keychainData: [String: String]!
    var coreData: [UUID: Telegraph.Account]!

    private func setupKeychain(size: Int, length: Int) {
        keychainData = [:]
        for _ in 0..<size {
            keychainData[String.random(length: length)] = String.random(length: length)
        }
    }

    private func setupCoreData(size: Int) {
        coreData = [:]
        for _ in 0..<size {
            coreData[UUID()] = Telegraph.Account.random()
        }
    }

    override func setUpWithError() throws {
        keychainData = [:]
        coreData = [:]
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        keychainData = nil
        coreData = nil
        try super.tearDownWithError()
    }

    func testKeychainRandom() throws {
        setupKeychain(size: 1_000, length: 100)

        keychainData.forEach {
            XCTAssert(Keychain.add(key: $0.key, value: $0.value), "Pair \($0) can't be added")
        }

        keychainData.forEach {
            XCTAssert($0.value == Keychain.copy(key: $0.key), "Pair \($0) not found")
            XCTAssert(Keychain.delete(key: $0.key), "Pair \($0) can't be deleted")
        }
    }

    func testCoreDataRandom() throws {
        setupCoreData(size: 1_000)

        coreData.forEach {
            XCTAssert(CoreData.save(uuid: $0.key, account: $0.value), "Pair \($0) can't be added")
        }

        XCTAssert(CoreData.fetch().count >= 1_000, "Data is not saved")

        coreData.forEach {
            XCTAssert(CoreData.delete(uuid: $0.key), "Pair \($0) can't be deleted")
        }
    }
}

extension String {
    static func random(length: Int) -> String {
        enum Statics {
            static let scalars = [UnicodeScalar("a").value...UnicodeScalar("z").value,
                                  UnicodeScalar("A").value...UnicodeScalar("Z").value,
                                  UnicodeScalar("0").value...UnicodeScalar("9").value].joined()

            static let characters = scalars.map { Character(UnicodeScalar($0)!) }
        }

        let result = (0..<length).map { _ in Statics.characters.randomElement()! }
        return String(result)
    }
}

extension Telegraph.Account: Equatable {
    public static func == (lhs: Telegraph.Account, rhs: Telegraph.Account) -> Bool {
        return lhs.accessToken == rhs.accessToken &&
               lhs.authUrl == rhs.authUrl &&
               lhs.authorName == rhs.authorName &&
               lhs.authorUrl == rhs.authorUrl &&
               lhs.pageCount == rhs.pageCount &&
               lhs.shortName == rhs.shortName
    }

    static func random() -> Telegraph.Account {
        return Telegraph.Account(
            shortName: String.random(length: 50),
            authorName: String.random(length: 50),
            authorUrl: String.random(length: 50),
            accessToken: String.random(length: 50),
            authUrl: String.random(length: 50),
            pageCount: Int.random(in: 0..<Int.max)
        )
    }
}
