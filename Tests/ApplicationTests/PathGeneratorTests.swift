//  Copyright © 2018 Jon. All rights reserved.

import XCTest
@testable import Application

class PathGeneratorTests: XCTestCase {

    static var allTests: [(String, (PathGeneratorTests) -> () throws -> Void)] {
        return [
            ("testRandomPathGeneratorLength", testRandomPathGeneratorLength),
            ("testStringsDoNotEqual", testStringsDoNotEqual),
            ("testExistingPaths", testExistingPaths),
        ]
    }
    
    func testRandomPathGeneratorLength() {
        let randomString = PathGenerator(length: 5).path
        XCTAssertEqual(randomString.count, 5)
        print("----- Random Generated String: \(randomString)")
    }

    func testStringsDoNotEqual() {
        // This test should almost always pass but there is a very, very slim
        // likelihood that the strings generated with be equal
        // Using a number with a higher probability of that happening (10)
        let randomString1 = PathGenerator.randomString(ofLength: 10)
        let randomString2 = PathGenerator.randomString(ofLength: 10)
        XCTAssertNotEqual(randomString1, randomString2, "The random strings generated appear to be the same.")
        print("----- First Random Generated String: \(randomString1)")
        print("----- Second Random Generated String: \(randomString2)")
    }

    func testExistingPaths() {
        let shortPaths = ShortPaths()
        XCTAssertTrue(shortPaths.existingPaths.isEmpty)

        let googleURLString = "https://google.com"
        let githubURLString = "https://github.com"
        // Adding a URL and Path
        XCTAssertTrue(shortPaths.add("XYZ", redirectURL: googleURLString), "Unable to add path")
        XCTAssertEqual(shortPaths.existingPaths["XYZ"], googleURLString)
        XCTAssertEqual(shortPaths.existingPaths.count, 1)
        XCTAssertTrue(shortPaths.doesPathExists("XYZ"))

        // Testing URL does not change when an entry already exists
        XCTAssertFalse(shortPaths.add("XYZ", redirectURL: githubURLString))
        XCTAssertEqual(shortPaths.existingPaths["XYZ"], googleURLString, "The redirect URL should not of chnaged")
        
        // Changing the existing path to a new URL using overwrite
        XCTAssertTrue(shortPaths.add("XYZ", redirectURL: githubURLString, overwrite: true))
        XCTAssertEqual(shortPaths.existingPaths["XYZ"], githubURLString, "The redirect URL should of been updated to the new URL")

        // Test removing a path from the `existingPaths`
        XCTAssertTrue(shortPaths.remove("XYZ"), "Unable to remove item from `exisitingPath`, it may not exist")
        XCTAssertNil(shortPaths.existingPaths["XYZ"])
        XCTAssertFalse(shortPaths.doesPathExists("XYZ"))
        XCTAssertFalse(shortPaths.remove("XYZ"), "Removing a path that is not there should return false")
    }
}
