//
//  IITMRemoteMessageUtil.swift
//  InstrumentITMobileIOSTracing
//
//  Created by NovaTec on 09.10.17.
//  Copyright © 2017 NovaTec. All rights reserved.
//

import UIKit

class IITMRemoteMessageUtil: IITMMessageUtil {
    
    // id starttime parent trace threadid threadname name url
    // requestLongitude requestLatitude requestNetworkConnection requestTimeout requestSsid requestNetworkProvider
    // 14
    // responseLongitude responseLatitude responseNetworkConnection responseTimeout responseSsid responseNetworkProvider
    // 20
    // responseCode endTime duration
    enum RemoteIdentifier {
        case id
        case parentId
        case traceId
        case startTime
        case endTime
        case duration
        case threadId
        case threadName
        case name
        
        case requestLongitude
        case requestLatitude
        case requestNetworkConnection
        case requestTimeout
        case requestSsid
        case requestNetworkProvider
        
        case responseLongitude
        case responseLatitude
        case responseNetworkConnection
        case responseTimeout
        case responseSsid
        case responseNetworkProvider
        case responseCode
        
        case url
    }
    
    func getRemoteCall(remotecall: IITMRemoteCall) -> String {
        return "\(uintToHex(int: remotecall.id)) \(String(describing: uintToHex(int: remotecall.startTime!))) \(String(describing: uintToHex(int: remotecall.parentId))) \(String(describing: uintToHex(int: remotecall.traceId))) \(uintToHex(int: UInt64(remotecall.threadId))) " +
        "\(remotecall.threadName) \(remotecall.name) \(String(describing: remotecall.url)) \(String(describing: remotecall.startPosition?.longitude)) " +
        "\(String(describing: remotecall.startPosition?.latitude)) \(String(describing: remotecall.startConnectivity)) \(String(describing: remotecall.timeout)) \(String(describing: remotecall.startSSID)) " +
        "\(String(describing: remotecall.startProvider)) \(String(describing: remotecall.endPosition?.longitude)) \(String(describing: remotecall.endPosition?.latitude)) " +
        "\(String(describing: remotecall.endConnectivity)) \(String(describing: remotecall.timeout)) \(String(describing: remotecall.endSSID)) \(String(describing: remotecall.endProvider)) " +
        "\(String(describing: remotecall.responseCode)) \(String(describing: uintToHex(int: remotecall.endTime!))) \(String(describing: uintToHex(int: remotecall.duration!)))"
        
    }
    
    override func getNumericValue(span: String, identifier: IITMRemoteMessageUtil.Identifier) -> UInt64 {
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
            if let endTime = UInt64(values[21], radix: 16) {
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
    
    override func getEndTime(span: String) -> UInt64 {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if let endTime = UInt64(values[21], radix: 16) {
            return endTime
        }
        return 0
    }
    
    func getUrl(span: String) -> String {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 7 {
            return values[7]
        }
        return "error: url not found"
    }
    
    func getRequestConnectivity(span: String) -> String {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 10 {
            return values[10]
        }
        return "error: request connectivity not found"
    }
    
    func getRequestLatitude(span: String) -> Double {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 9 {
            if let latitude = Double(values[9]) {
                return latitude
            }
        }
        return 0
    }
    
    func getRequestLongitude(span: String) -> Double {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 8 {
            if let longitude = Double(values[8]) {
                return longitude
            }
        }
        return 0
    }
    
    func getRequestSSID(span: String) -> String {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 12 {
            return values[12]
        }
        return "error: request SSID not found"
    }
    
    func getRequestProvider(span: String) -> String {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 13 {
            return values[13]
        }
        return "error: request provider not found"
    }
    
    func getRequestResponseCode(span: String) -> Int {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 20 {
            if let code = Int(values[20]) {
                return code
            }
        }
        return 0
    }
    
    func getRequestTimeout(span: String) -> Bool {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 11 {
            if let timeout = Bool(values[11]) {
                return timeout
            }
        }
        return false
    }
    
    func getResponseConnectivity(span: String) -> String {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 16 {
            return values[16]
        }
        return "error: request connectivity not found"
    }
    
    func getResponseLatitude(span: String) -> Double {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 15 {
            if let latitude = Double(values[15]) {
                return latitude
            }
        }
        return 0
    }
    
    func getResponseLongitude(span: String) -> Double {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 14 {
            if let longitude = Double(values[14]) {
                return longitude
            }
        }
        return 0
    }
    
    func getResponseSSID(span: String) -> String {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 18 {
            return values[18]
        }
        return "error: request SSID not found"
    }
    
    func getResponseProvider(span: String) -> String {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 19 {
            return values[19]
        }
        return "error: request provider not found"
    }
    
    func getResponseCode(span: String) -> Int {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 20 {
            if let code = Int(values[20]) {
                return code
            }
        }
        return 0
    }
    
    func getResponseTimeout(span: String) -> Bool {
        let nsspan = span as NSString
        let values = nsspan.components(separatedBy: " ")
        if values.count > 17 {
            if let timeout = Bool(values[17]) {
                return timeout
            }
        }
        return false
    }

    
    override func convertToJson(span: String) -> [String : Any] {
        var serializedInvocation: [String : Any] = [String : Any]()
        var tags: [String : Any] = [String : Any]()
        var spanContext: [String : Any] = [String : Any]()
        serializedInvocation["operationName"] = getName(span: span)
        serializedInvocation["startTimeMicros"] = getStartTime(span: span)
        serializedInvocation["duration"] = getEndTime(span: span) - getStartTime(span: span)
        tags["http.url"] = getUrl(span: span)
        tags["http.request.networkConnection"] = getRequestConnectivity(span: span)
        tags["http.request.latitude"] = getRequestLatitude(span: span)
        tags["http.request.longitude"] = getRequestLongitude(span: span)
        tags["http.request.ssid"] = getRequestSSID(span: span)
        tags["http.request.networkProvider"] = getRequestProvider(span: span)
        tags["http.request.responseCode"] = getRequestResponseCode(span: span)
        tags["http.request.timeout"] = getRequestTimeout(span: span)
        tags["http.response.networkConnection"] = getResponseConnectivity(span: span)
        tags["http.response.latitude"] = getResponseLatitude(span: span)
        tags["http.response.longitude"] = getResponseLongitude(span: span)
        tags["http.response.ssid"] = getResponseSSID(span: span)
        tags["http.response.networkProvider"] = getRequestProvider(span: span)
        tags["http.response.timeout"] = getResponseTimeout(span: span)
        tags["ext.propagation.type"] = "HTTP"
        tags["span.kind"] = "client"
        serializedInvocation["tags"] = tags
        spanContext["id"] = getId(span: span)
        spanContext["traceId"] = getTraceId(span: span)
        spanContext["parentId"] = getParentId(span: span)
        serializedInvocation["spanContext"] = spanContext
        return serializedInvocation
    }
    
    
    
    
}
