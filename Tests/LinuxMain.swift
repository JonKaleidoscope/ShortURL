import XCTest

@testable import ApplicationTests

XCTMain([
    testCase(PathGeneratorTests.allTests),
    testCase(RouteTests.allTests),
    testCase(StringUtils_Tests.allTests),
    ])
