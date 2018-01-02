//
//  Util.swift
//  AutomaticInvocationTracker
//
//  Created by Matteo Sassano on 15.05.17.
//  Copyright © 2017 Matteo Sassano. All rights reserved.
//

import Foundation

class Util: NSObject {
    
    static func condenseWhitespace(string: String) -> String {
        return string.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
}

public let defaultTimestampMultiplier = 1000000.0

public func getTimestamp(multiplier: Double? = defaultTimestampMultiplier) -> UInt64 {
    return UInt64(NSDate().timeIntervalSince1970 * multiplier!)
}

public func decimalToHex(decimal: UInt64) -> String {
    return String(decimal, radix: 16)
}

public func calculateUuid() -> UInt64 {
//    let uuid1 : UInt64 = UInt64(UUID().hashValue)
//    let uuid2 : UInt64 = UInt64(UUID().hashValue)
//    return uuid1 << 0x20 | uuid2
    let hex = UUID().uuidString
        .components(separatedBy: "-")
        .suffix(2)
        .joined()
    
    return UInt64(hex, radix: 0x10)!
}
