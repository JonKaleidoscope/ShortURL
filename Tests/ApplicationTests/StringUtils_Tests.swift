//  Copyright © 2018 Jon. All rights reserved.

import XCTest
@testable import Application

class StringUtils_Tests: XCTestCase {

    static var allTests: [(String, (StringUtils_Tests) -> () throws -> Void)] {
        return [
            ("testRemoveLeadingSlash", testRemoveLeadingSlash),
            ("testRemovedLeadingSlash_NonMutating", testRemovedLeadingSlash_NonMutating),
        ]
    }

    func testRemoveLeadingSlash() {
        // These strings must be variables because they will mutate
        var leadingSlash1 = "/-JLO"
        var leadingSlash2 = "//X_Y_Z"
        var emptyString = ""
        var noLeadingSlash = "LMNO"

        XCTAssertEqual(leadingSlash1.removeLeadingSlash(), "-JLO")
        XCTAssertEqual(leadingSlash1, "-JLO")
        XCTAssertEqual(leadingSlash2.removeLeadingSlash(), "/X_Y_Z")
        XCTAssertEqual(leadingSlash2, "/X_Y_Z")
        XCTAssertEqual(leadingSlash2.removeLeadingSlash(), "X_Y_Z")
        XCTAssertEqual(leadingSlash2, "X_Y_Z")
        XCTAssertEqual(leadingSlash2.removeLeadingSlash(), "X_Y_Z")
        XCTAssertEqual(leadingSlash2, "X_Y_Z")
        XCTAssertEqual(emptyString.removeLeadingSlash(), "")
        XCTAssertEqual(emptyString, "")
        XCTAssertEqual(noLeadingSlash.removeLeadingSlash(), "LMNO")
        XCTAssertEqual(noLeadingSlash, "LMNO")
    }

    func testRemovedLeadingSlash_NonMutating() {
        let leadingSlash1 = "/-JLO"
        let leadingSlash2 = "//X_Y_Z"
        let emptyString = ""
        let noLeadingSlash = "LMNO"

        XCTAssertEqual(leadingSlash1.removedLeadingSlash, "-JLO")
        XCTAssertEqual(leadingSlash2.removedLeadingSlash, "/X_Y_Z")
        XCTAssertEqual(leadingSlash2.removedLeadingSlash, "/X_Y_Z")
        XCTAssertEqual(leadingSlash2.removedLeadingSlash.removedLeadingSlash, "X_Y_Z")
        XCTAssertEqual(emptyString.removedLeadingSlash, "")
        XCTAssertEqual(noLeadingSlash.removedLeadingSlash, "LMNO")
    }
}
