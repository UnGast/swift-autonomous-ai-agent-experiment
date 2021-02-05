import XCTest
@testable import swift_ai

final class swift_aiTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(swift_ai().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
