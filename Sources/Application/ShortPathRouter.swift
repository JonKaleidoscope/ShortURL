//  Copyright © 2018 Jon. All rights reserved.

import Foundation
import Kitura

class ShortPathRouter: RouterMiddleware {

    let shortPaths: ShortPaths = {
        let sp = ShortPaths()
        sp.add("ABC", redirectURL: "https://google.com")
        sp.add("LMNOP", redirectURL: "https://github.com")
        sp.add("amz", redirectURL: "https://amazon.com")
        return sp
    }()

    func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        defer { next() }
    }

    /// Registers the already existing routes that have redirects
    func registerShortPaths(app: App) {
        // TODO: Move count for each URL hit to persistent storage
        var count = 0
        shortPaths.existingPaths.forEach { (path, redirect) in
            app.router.get(path, handler: { (req, res, next) in
                try res.redirect(redirect, status: .temporaryRedirect)
                count += 1
            })
        }
    }
}
