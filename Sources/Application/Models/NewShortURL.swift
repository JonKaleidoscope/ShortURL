//  Copyright © 2018 Jon. All rights reserved.

import Foundation

struct NewShortURL: Codable {
    let suggestedPath: String?
    let redirectURL: String
}

extension NewShortURL {
    /// Returns JSON data representation of model
    var json: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(self)
    }
}
