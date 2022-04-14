import XCTest
@testable import EFKeychain

final class EFKeychainTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(EFKeychain().text, "Hello, World!")
    }
}
