//  Copyright © 2018 Jon. All rights reserved.

import Foundation

extension String {

    /// Saftely removing the leading forward slash at the beginning of a string.
    /// If there is no leading forward slash, then nothing will be removed.
    @discardableResult
    mutating func removeLeadingSlash() -> String {
        let char = self.first
        guard char == Character("/") else { return self }
        removeFirst()
        
        return self
    }

    /// Saftely remove the first forward slash at the beginning of a string.
    /// If there is no leading forward slash, then nothing will be removed.
    var removedLeadingSlash: String {
        var tempString = self
        tempString.removeLeadingSlash()
        return tempString
    }
}
