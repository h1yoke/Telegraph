import XCTest
@testable import Telegraph

// Dummy profile initializer for testing purposes
fileprivate extension Profile {
    convenience init?() {
        self.init(newAccount: Telegraph.Account(accessToken: ""))
    }
}

class ProfileManagerTests: XCTestCase {
    var sut: ProfileManager!

    private func generateProfiles(size: Int) -> [Profile?] {
        return Array(repeating: Profile(), count: size)
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ProfileManager.shared
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testStressAdd() {
        measure {
            // Add 1000 profiles to storage system
            generateProfiles(size: 1_000).forEach {
                guard let prf = $0 else {
                    XCTAssert(false, "Profile can't initialize")
                    return
                }
                XCTAssert(sut.add(profile: prf), "Profile \(prf) can't be added")
            }
            // Clear all profiles
            while sut.count > 0 {
                sut.delete(id: 0)
            }
        }
    }

    func testCurrent() {
        let prf1 = Profile(), prf2 = Profile()
        sut.current = prf1
        XCTAssert(prf1 === sut.current!, "Current profile can't be added")
        sut.current = prf2
        XCTAssert(prf1 !== prf2 && prf2 === sut.current!, "Current profile can't be changed")
    }
}
