//  Copyright © 2018 Jon. All rights reserved.

import Foundation

struct PathGenerator {

    let path: String

    init(length: Int = 5) {
        path = PathGenerator.randomString(ofLength: length)
    }

    /**
     Random string generator containing alphanumeric case sensitve letters.

     - parameter ofLength: The length of the designated random string output.
     - returns: A random string.
    */
    static func randomString(ofLength: Int) -> String {
        // Letters used in path are alphanumeric and case sensitive
        // Other characters can exist in the path ie `-`, `_` ,`+`, etc.
        // In the future, consider including and supporting other characters
        // For more information: https://perishablepress.com/stop-using-unsafe-characters-in-urls/
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.count)

        var randomString = ""
        for _ in 0 ..< ofLength {
            let rand = arc4random_uniform(len)
            let index = letters.index(letters.startIndex, offsetBy: Int(rand))
            let nextChar = String(letters[index])
            randomString += nextChar
        }

        return randomString
    }
}

// Temporary object that will hold the existing paths
// TODO: Replace object with database and query for existing entries
class ShortPaths {
    /// Represents the path and the URL that will be redirected to.
    /// ie. each path is mapped to a URL where a user will be taking to
    /// "abc" -> "https://google.com"
    private (set) var existingPaths = [String: String]()

    func doesPathExists(_ path: String) -> Bool {
        return existingPaths.keys.contains(path)
    }

    @discardableResult
    func add(_ path: String, redirectURL: String, overwrite: Bool = false) -> Bool {
        if overwrite {
            existingPaths[path] = redirectURL
            return true
        }

        guard let _ = existingPaths[path] else {
            // Value does not exist so it is safe to add it
            existingPaths[path] = redirectURL
            return true
        }

        // The path already exists it is not safe to add it
        return false
    }

    @discardableResult
    func remove(_ path: String) -> Bool {
        guard let index = existingPaths.index(forKey: path) else { return false }

        existingPaths.remove(at: index)
        return true
    }
}
