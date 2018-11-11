//  Copyright © 2018 Jon. All rights reserved.

import Foundation
import Kitura
import Health
import CloudEnvironment

public let health = Health()
func initializeHealthRoutes(on router: Router) {

    router.get("/health") { (respondWith: (Status?, RequestError?) -> Void) -> Void in
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

    // MARK: - Functions
    public init() throws {
    }

    func postInit() throws {
        // Endpoints
        initializeHealthRoutes(on: router)
        router.get(middleware: ShortPathRouter())
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
}

