//  Copyright © 2018 Jon. All rights reserved.

import Foundation
import Kitura
import Health
import CloudEnvironment

public class App {
    // MARK: - Properties
    let router = Router()
    let cloudEnv = CloudEnv()
    // Holding a strong reference to `ShortPathRouter` inorder to maintain the state it holds.
    // Without it, updates to existing URLs will not persist.
    let spr = ShortPathRouter()

    // MARK: - Functions
    public init() throws {
    }

    func postInit() throws {
        // Endpoints
        HealthChecker.initializeHealthRoutes(on: router)

        router.get(middleware: spr)
        router.post(middleware: spr)
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
}
