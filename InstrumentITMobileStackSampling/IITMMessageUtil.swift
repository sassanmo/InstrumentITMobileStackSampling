//
//  IITMMessageUtil.swift
//  InstrumentITMobileIOSTracing
//
//  Created by NovaTec on 05.10.17.
//  Copyright © 2017 NovaTec. All rights reserved.
//

import UIKit

class IITMMessageUtil: NSObject {
    
    // id starttime parent trace threadid threadname name endTime duration
    enum Identifier {
        case id
        case parentId
        case traceId
        case startTime
        case endTime
        case duration
        case threadId
        case threadName
        case name
    }
    
    override init() { }
    
    func getSpanString(span: IITMInvocation) -> String {
        return "\(uintToHex(int: span.id)) \(uintToHex(int: span.startTime!)) \(uintToHex(int: span.parentId)) \(uintToHex(int: span.traceId)) " + "\(uintToHex(int: UInt64(span.threadId))) \(span.threadName) \(span.name)"
    }
    
    func completeSpanString(span: IITMInvocation) -> String {
        return "\(uintToHex(int: span.id)) \(String(describing: uintToHex(int: span.startTime!))) \(String(describing: uintToHex(int: span.parentId))) \(String(describing: uintToHex(int: span.traceId))) \(uintToHex(int: UInt64(span.threadId))) \(span.threadName) \(span.name) \(String(describing: uintToHex(int: span.endTime!))) \(String(describing: uintToHex(int: span.duration!)))"
    }
    
    func uintToHex(int: UInt64) -> String {
        var totalHex = ""
        let hex = String(int, radix: 16)
        totalHex = hex
        return totalHex
    }
    
    func hexToUint(string: String) -> UInt64 {
        if let decimal = UInt64(string, radix: 16) {
            return decimal
        }
        return 0
    }
    
    func getStringValue(span: String, identifier: Identifier) -> String {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        switch identifier {
        case .threadName:
            return values[5]
        case .name:
            return values[6]
        default:
            return "error"
        }
    }
    
    func getNumericValue(span: String, identifier: Identifier) -> UInt64 {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        switch identifier {
        case .id:
            if let id = UInt64(values[0], radix: 16) {
                return id
            }
            break
        case .parentId:
            if let parentId = UInt64(values[2], radix: 16) {
                return parentId
            }
            break
        case .traceId:
            if let traceId = UInt64(values[3], radix: 16) {
                return traceId
            }
            break
        case .threadId:
            if let threadId = UInt64(values[4], radix: 16) {
                return threadId
            }
            break
        case .endTime:
            if let endTime = UInt64(values[7], radix: 16) {
                return endTime
            }
            break
        case .startTime:
            if let startTime = UInt64(values[1], radix: 16) {
                return startTime
            }
            break
        default:
            return 0
        }
        return 0
    }
    
    func getId(span: String) -> UInt64 {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if let id = UInt64(values[0], radix: 16) {
            return id
        }
        return 0
    }
    
    func getParentId(span: String) -> UInt64 {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if let parentId = UInt64(values[2], radix: 16) {
            return parentId
        }
        return 0
    }
    
    func getTraceId(span: String) -> UInt64 {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if let traceId = UInt64(values[3], radix: 16) {
            return traceId
        }
        return 0
    }
    
    func getStartTime(span: String) -> UInt64 {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if let startTime = UInt64(values[1], radix: 16) {
            return startTime
        }
        return 0
    }
    
    func getEndTime(span: String) -> UInt64 {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if let endTime = UInt64(values[7], radix: 16) {
            return endTime
        }
        return 0
    }
    
    func getThreadId(span: String) -> UInt {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if let startTime = UInt(values[4], radix: 16) {
            return startTime
        }
        return 0
    }
    
    func getName(span: String) -> String {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 6 {
            return values[6]
        }
        return "error: name not found"
    }
    
    func getThreadName(span: String) -> String {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 5 {
            return values[5]
        }
        return "error: threadname not found"
    }
    
    func convertToJson(span: String) -> [String : Any] {
        var serializedInvocation: [String : Any] = [String : Any]()
        var tags: [String : Any] = [String : Any]()
        var spanContext: [String : Any] = [String : Any]()
        serializedInvocation["operationName"] = getName(span: span)
        serializedInvocation["startTimeMicros"] = getStartTime(span: span)
        serializedInvocation["duration"] = getEndTime(span: span) - getStartTime(span: span)
        tags["span.kind"] = "client"
        tags["ext.propagation.type"] = "IOS"
        serializedInvocation["tags"] = tags
        spanContext["id"] = getId(span: span)
        spanContext["traceId"] = getTraceId(span: span)
        spanContext["parentId"] = getParentId(span: span)
        serializedInvocation["spanContext"] = spanContext
        return serializedInvocation
    }
}
