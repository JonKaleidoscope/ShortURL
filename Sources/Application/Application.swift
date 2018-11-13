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

        router.all("/") { (req, res, next) in
            // Currently the "POST" for adding new `ShortURLs` operates on the `/` home page path.
            // Any other HTTP methods should return a `Bad Request`.
            if req.method == .post { next(); return }

            // This function is also here for removing the default Kitura home page
            // that is constucted when no response is generated for this path.
            // Placing the logic before the `router.get(middleware: spr)` for quicker failure, visibilty,
            // and keeping logic out of the `ShortPathRouter`.
            // If this function is not here, for a GET, a look up is performed in the
            // `ShortPathRouter` and will return `404 Not Found`.
            // For all other requests the Kitura help home page is loaded.
            try res.status(.badRequest).end()
        }
        router.get(middleware: spr)
        router.post(middleware: spr)
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
}
