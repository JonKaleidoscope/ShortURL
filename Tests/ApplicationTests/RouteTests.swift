import Foundation
import Kitura
import KituraNet
import XCTest
import HeliumLogger
import LoggerAPI

@testable import Application

class RouteTests: XCTestCase {
    // There is state held in the `App` class and it needs to be retained
    static var app: App!
    static var port: Int!
    static var url: String!
    static var allTests: [(String, (RouteTests) -> () throws -> Void)] {
        return [
            //("testGetStatic", testGetStatic),
            ("testRouteTestsProperties", testRouteTestsProperties),
            ("testBadRequest", testBadRequest),
            ("testBadRequestOnHomePage", testBadRequestOnHomePage),
            ("testHealthRoute", testHealthRoute),
            ("testSampleShortPaths", testSampleShortPaths),
            ("testPOST_NewShortURLCreated", testPOST_NewShortURLCreated),
        ]
    }

    override func setUp() {
        super.setUp()

        HeliumLogger.use()
        do {
            print("------------------------------")
            print("------------New Test----------")
            print("------------------------------")

            RouteTests.app = try App()
            RouteTests.port = RouteTests.app.cloudEnv.port
            // Using `String(RouteTests.port)` because `\(RouteTests.port)` returning Optional(8080)
            // Since the `RouteTests.port` is an implicitly unwrapped optional,
            // its `description` returns its optional value representation
            RouteTests.url = "http://127.0.0.1:" + String(RouteTests.port)
            try RouteTests.app.postInit()
            Kitura.addHTTPServer(onPort: RouteTests.port, with: RouteTests.app.router)
            Kitura.start()
        } catch {
            XCTFail("Couldn't start Application test server: \(error)")
        }
    }

    override func tearDown() {
        Kitura.stop()
        RouteTests.port = nil
        RouteTests.url = nil
        RouteTests.app = nil
        super.tearDown()
    }

    func testRouteTestsProperties() {
        XCTAssertEqual(RouteTests.port, 8080)
        XCTAssertEqual(RouteTests.url, "http://127.0.0.1:8080")
        XCTAssertEqual(RouteTests.allTests.count, 6,
                       "This number should increase as the Linux tests increase.")
    }

    func testBadRequest() {
        let methods = ["PUT", "HEAD", "DELETE", "PATCH"]
        let requestExpectation = expectation(description: "Home Page Request")
        requestExpectation.expectedFulfillmentCount = methods.count

        for method in methods {
            let randomPath = PathGenerator.randomString(ofLength: 2)
            var request = URLRequest(forTestWithMethod: method, route: randomPath)
            request?.cachePolicy = .reloadIgnoringCacheData
            request?.sendForTestingWithKitura { data, statusCode in
                requestExpectation.fulfill()
                XCTAssertEqual(statusCode, 404, "\(method): Not returning `Not Found` on \(randomPath).")
            }
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testBadRequestOnHomePage() {
        let methods = ["GET", "PUT", "HEAD", "DELETE", "PATCH"]
        let requestExpectation = expectation(description: "Home Page Request")
        requestExpectation.expectedFulfillmentCount = methods.count

        for method in methods {
            var request = URLRequest(forTestWithMethod: method, route: "/")
            request?.cachePolicy = .reloadIgnoringCacheData
            request?.sendForTestingWithKitura { _, statusCode in
                requestExpectation.fulfill()
                XCTAssertEqual(statusCode, 400, "\(method): Not returning `Bad Request`.")
            }
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /*
    func testGetStatic() {
        let printExpectation = expectation(description: "The /route will serve static HTML content.")

        URLRequest(forTestWithMethod: "GET")?
            .sendForTestingWithKitura { data, statusCode in
                if let getResult = String(data: data, encoding: String.Encoding.utf8){
                    XCTAssertEqual(statusCode, 200)
                    XCTAssertTrue(getResult.contains("<html"))
                    XCTAssertTrue(getResult.contains("</html>"))
                } else {
                    XCTFail("Return value from / was nil!")
                }

                printExpectation.fulfill()
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }
    */

    func testSampleShortPaths() {
        // This test makes calls to the internet, so an actual connection is needed.
        let samplePaths = [
            //"health": "localhost:8080/health/check",
            "ABC": "https://google.com",
            "amz": "https://amazon.com",
            ]
        let requestExpectation = expectation(description: "The Sample ShortURLs")
        requestExpectation.expectedFulfillmentCount = samplePaths.count

        for (path, _) in samplePaths {
            var request = URLRequest(forTestWithMethod: "GET", route: path)
            request?.cachePolicy = .reloadIgnoringCacheData
            request?.sendForTestingWithKitura { data, statusCode in
                XCTAssertEqual(statusCode, 200, "\(path) not returning successfully.")
            }
            requestExpectation.fulfill()
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testPOST_NewShortURLCreated() {
        let createdExpectation = expectation(description: "New Short URL Created.")
        let testNewlyAddedRoute = { [unowned self] (shortURL: String) in
            self.testHealth(route: shortURL)
        }

        // Testing with localhost `127.0.0.1` because it does not require internet for validation
        let expectedRedirect = RouteTests.url + "/health/check"
        let body = NewShortURL(suggestedPath: nil, redirectURL: expectedRedirect).json
        let request = URLRequest(forTestWithMethod: "POST", route: "/", body: body)
        request?.sendForTestingWithKitura { data, statusCode in
            createdExpectation.fulfill()
            XCTAssertEqual(statusCode, 201,
                           "The `statusCode` does not equal the expected 201, it mave have need altered.")

            let decoder = JSONDecoder()
            guard let result = try? decoder.decode(RedirectContent.self, from: data) else {
                return XCTFail("Unable to create `RedirectContent`")
            }

            XCTAssertEqual(result.redirectURL, expectedRedirect)
            let shortURL = result.shortURL
            XCTAssertEqual(shortURL.count, 5)

            // Testing the shortURL that was added to validate it has been save.
            // This will also test that we are able to be taken to that URL successfully
            testNewlyAddedRoute(shortURL)
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testHealthRoute() {
        testHealth()

        // Adding `shortURL` `health` to the existing routes
        let healthCeckURL = RouteTests.app.cloudEnv.url + HealthChecker.route
        XCTAssertEqual(HealthChecker.route, "/health/check")
        XCTAssertEqual(healthCeckURL, "http://localhost:8080/health/check")
        XCTAssertTrue(RouteTests.app.spr.add("health", redirectURL: healthCeckURL),
                      "Unable to add `health` route")
        testHealth(route: "health")
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testHealth(route: String = "health/check") {
        let printExpectation = expectation(description: "The /health route will print UP, followed by a timestamp.")
        URLRequest(forTestWithMethod: "GET", route: route)?
            .sendForTestingWithKitura { data, statusCode in
                if let getResult = String(data: data, encoding: String.Encoding.utf8) {
                    XCTAssertEqual(statusCode, 200)
                    XCTAssertTrue(getResult.contains("UP"), "UP not found in the result.")
                    let date = Date()
                    let calendar = Calendar.current
                    let yearString = String(describing: calendar.component(.year, from: date))
                    XCTAssertTrue(getResult.contains(yearString), "Failed to create String from date. Date is either missing or incorrect.")
                } else {
                    XCTFail("Unable to convert request Data to String.")
                }
                printExpectation.fulfill()
        }
    }
}

private extension URLRequest {

    init?(forTestWithMethod method: String, route: String = "", body: Data? = nil) {
        if let url = URL(string: RouteTests.url + "/" + route) {
            self.init(url: url)
            addValue("application/json", forHTTPHeaderField: "Content-Type")
            httpMethod = method
            cachePolicy = .reloadIgnoringCacheData
            if let body = body {
                httpBody = body
            }
        } else {
            XCTFail("URL is nil...")
            return nil
        }
    }

    func sendForTestingWithKitura(fn: @escaping (Data, Int) -> Void) {

        guard let method = httpMethod, var path = url?.path, let headers = allHTTPHeaderFields else {
            XCTFail("Invalid request params")
            return
        }

        if let query = url?.query {
            path += "?" + query
        }

        let requestOptions: [ClientRequest.Options] = [.method(method), .hostname("localhost"), .port(8080), .path(path), .headers(headers)]

        let req = HTTP.request(requestOptions) { resp in

            if let resp = resp,
                resp.statusCode == HTTPStatusCode.OK ||
                resp.statusCode == HTTPStatusCode.accepted ||
                resp.statusCode == HTTPStatusCode.created {
                do {
                    var body = Data()
                    try resp.readAllData(into: &body)
                    fn(body, resp.statusCode.rawValue)
                } catch {
                    print("Bad JSON document received from Kitura-Starter.")
                }
            } else {
                if let resp = resp {
                    print("Status code: \(resp.statusCode)")
                    var rawData = Data()
                    do {
                        let _ = try resp.read(into: &rawData)
                        let str = String(data: rawData, encoding: String.Encoding.utf8)
                        print("Error response from Kitura-Starter: \(String(describing: str))")
                        fn(rawData, resp.statusCode.rawValue)
                    } catch {
                        print("Failed to read response data.")
                    }
                }
            }
        }
        if let dataBody = httpBody {
            req.end(dataBody)
        } else {
            req.end()
        }
    }
}
