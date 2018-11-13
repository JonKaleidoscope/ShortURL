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
        // Previous handler has already set the status and response no need to continue
        if response.statusCode == .OK { next(); return }

        switch request.method {
        case .get:
            try redirector(request: request, response: response, next: next)
        case .post:
            try updater(request: request, response: response, next: next)
        default:
            // Other methods are not support will return the generic 404
            try response.status(.notFound).end()
        }
    }

    private func redirector(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        let urlPath = request.urlURL.path.removedLeadingSlash
        // Grabbing the redirect URL destination
        guard let destination = shortPaths.existingPaths[urlPath] else {
            try response.status(.notFound).end()
            return
        }

        try response.redirect(destination, status: .temporaryRedirect)
    }

    private func updater(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        var data = Data()
        guard let _ = try? request.read(into: &data) else {
            try response.status(.badRequest).end()
            return
        }

        guard let newShortURL = try? JSONDecoder().decode(NewShortURL.self, from: data) else {
            try response.status(.badRequest).end()
            return
        }

        let redirectURL = newShortURL.redirectURL

        // Creating New Random Path and adding it to existing paths
        let newShortPath = PathGenerator().path
        guard shortPaths.add(newShortPath, redirectURL: redirectURL) else {
            // This should only really happen when there is a collision in created path
            try response.status(.internalServerError).end()
            return
        }

        let json = RedirectContent(shortURL: newShortPath, redirectURL: redirectURL)
        try response.status(.created).send(json: json).end()
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

    @discardableResult
    func add(_ path: String, redirectURL: String, overwrite: Bool = false) -> Bool {
        return shortPaths.add(path, redirectURL: redirectURL, overwrite: overwrite)
    }
}
