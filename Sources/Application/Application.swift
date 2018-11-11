//  Copyright © 2018 Jon. All rights reserved.

import Foundation
import Kitura
import Health
import CloudEnvironment

public let health = Health()
extension Health {
    static var route: String { return "/health/check" }
}
let healthRoute = "/health/check"
func initializeHealthRoutes(on router: Router) {
    // Changing the health route to a deep level path because
    // all the top level paths are reserved for the short URLs
    router.get(Health.route) { (respondWith: (Status?, RequestError?) -> Void) -> Void in
        if health.status.state == .UP {
            respondWith(health.status, nil)
        } else {
            respondWith(nil, RequestError(.serviceUnavailable, body: health.status))
        }
    }
}

public class App {
    // MARK: - Properties
    let router = Router()
    let cloudEnv = CloudEnv()
    // Holding strong reference to `ShortPathRouter` inorder to maintain the state it holds.
    // Without it, updates to existing URLs will not persist
    let spr = ShortPathRouter()

    // MARK: - Functions
    public init() throws {
    }

    func postInit() throws {
        // Endpoints
        initializeHealthRoutes(on: router)
        //router.get(middleware: ShortPathRouter())
        let healthCeckURL = cloudEnv.url + Health.route
        spr.shortPaths.add("health", redirectURL: healthCeckURL)
        router.get(middleware: spr)
        router.post(middleware: spr)
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
}

