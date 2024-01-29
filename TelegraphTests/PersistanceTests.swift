import XCTest
@testable import Telegraph

// Dummy profile initializer for testing purposes
fileprivate extension Profile {
    convenience init?() {
        self.init(newAccount: Telegraph.Account(accessToken: ""))
    }
}

fileprivate extension String {
    static func random(length: Int) -> String {
        enum Statics {
            static let scalars = [UnicodeScalar("a").value...UnicodeScalar("z").value,
                                  UnicodeScalar("A").value...UnicodeScalar("Z").value,
                                  UnicodeScalar("0").value...UnicodeScalar("9").value].joined()
            static let characters = scalars.map { Character(UnicodeScalar($0)!) }
        }
        return String((0..<length).map { _ in Statics.characters.randomElement()! })
    }
}

class PersistanceTests: XCTestCase {
    var keychainData: [String: String]!
    var coreData: [UUID: Profile]!

    private func setupKeychain(size: Int, length: Int) {
        keychainData = [:]
        for _ in 0..<size {
            keychainData[String.random(length: length)] = String.random(length: length)
        }
    }

    private func setupCoreData(size: Int) {
        coreData = [:]
        for _ in 0..<size {
            coreData[UUID()] = Profile()
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
            XCTAssert(CoreData.save(uuid: $0.key, profile: $0.value), "Pair \($0) can't be added")
        }

        XCTAssert(CoreData.fetch().count >= 1_000, "Data is not saved")

        coreData.forEach {
            XCTAssert(CoreData.delete(uuid: $0.key), "Pair \($0) can't be deleted")
        }
    }
}
