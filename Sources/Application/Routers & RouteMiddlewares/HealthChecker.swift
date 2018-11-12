//  Copyright © 2018 Jon. All rights reserved.

import Foundation
import Kitura
import Health

/**
 Lightweight struct for attaining health information and to better organizing the code.

 Health information captured pretty well right out of the box.
 If more customization is needed, consider conforming to `HealthProtocol`.
 */
struct HealthChecker {
    static var route: String { return "/health/check" }

    static func initializeHealthRoutes(on router: Router) {
        let health = Health()
        // Changing the health route to a deep level path because
        // all the top level paths are reserved for the short URLs
        router.get(HealthChecker.route) { (respondWith: (Status?, RequestError?) -> Void) -> Void in
            if health.status.state == .UP {
                respondWith(health.status, nil)
            } else {
                respondWith(nil, RequestError(.serviceUnavailable, body: health.status))
            }
        }
    }
}
