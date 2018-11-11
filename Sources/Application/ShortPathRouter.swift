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
        let urlPath = safelyRemoveForwardSlash(request.urlURL.path)
        // Grabbing the redirect URL destination
        guard let destination = shortPaths.existingPaths[urlPath] else {
            try response.status(.notFound).end()
            return
        }

        try response.redirect(destination, status: .temporaryRedirect)
    }

    /// Registers the already existing routes that have redirects
    func registerShortPaths(to app: App) {
        registerShortPaths(to: app.router)
    }

    /// Registers the already existing routes that have redirects
    func registerShortPaths(to router: Router) {
        // TODO: Move count for each URL hit to persistent storage
        var count = 0
        shortPaths.existingPaths.forEach { (path, redirect) in
            router.get(path, handler: { (req, res, next) in
                try res.redirect(redirect, status: .temporaryRedirect)
                count += 1
            })
        }
    }

    func safelyRemoveForwardSlash(_ urlPath: String) -> String {
        let char = urlPath.first
        guard char == Character("/") else { return urlPath }
        var shortenPath = urlPath
        shortenPath.removeFirst()

        return shortenPath
    }
}
