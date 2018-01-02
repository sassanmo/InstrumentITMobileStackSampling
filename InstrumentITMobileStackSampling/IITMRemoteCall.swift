//
//  RemoteCall.swift
//  AutomaticInvocationTracker
//
//  Created by Matteo Sassano on 22.05.17.
//  Copyright © 2017 Matteo Sassano. All rights reserved.
//

import Foundation
import CoreLocation

public class IITMRemoteCall: IITMInvocation {
    
    var timeout: Bool?
    
    var responseCode: Int?
    
    var startPosition: CLLocationCoordinate2D?
    
    var endPosition: CLLocationCoordinate2D?
    
    var startProvider: String?
    
    var endProvider: String?
    
    var startConnectivity: String?
    
    var endConnectivity: String?
    
    var startSSID: String?
    
    var endSSID: String?
    
    var httpMethod : String?
    
    var url : String?
    
    override init(name: String) {
        super.init(name: name)
        self.url = name
    }
    
    init(name: String, holder: String, url: String) {
        super.init(name: name, holder: holder)
        self.url = url
    }
    
    // TODO: Response and error
    func closeRemoteCall(response: URLResponse?, error: Error?) {
        self.ended = true
        self.endTime = getTimestamp()
        if let endtime = self.endTime, let starttime = self.startTime {
            self.duration = endtime - starttime
        }
    }
    
    override func getInvocationMap() -> [String : Any] {
        var serializedInvocation: [String : Any] = [String : Any]()
        var tags: [String : Any] = [String : Any]()
        var spanContext: [String : Any] = [String : Any]()
        serializedInvocation["operationName"] = "\(self.name) (\(String(describing: self.url)))"
        serializedInvocation["startTimeMicros"] = self.startTime
        serializedInvocation["duration"] = self.duration
        tags["http.url"] = self.url
        tags["http.request.networkConnection"] = self.startConnectivity
        tags["http.request.latitude"] = self.startPosition?.latitude
        tags["http.request.longitude"] = self.startPosition?.longitude
        tags["http.request.ssid"] = self.startSSID
        tags["http.request.networkProvider"] = self.startProvider
        tags["http.request.responseCode"] = self.responseCode
        tags["http.request.timeout"] = self.timeout
        tags["http.response.networkConnection"] = self.endConnectivity
        tags["http.response.latitude"] = self.endPosition?.latitude
        tags["http.response.longitude"] = self.endPosition?.longitude
        tags["http.response.ssid"] = self.endSSID
        tags["http.response.networkProvider"] = self.endProvider
        tags["http.response.timeout"] = self.timeout
        tags["ext.propagation.type"] = "HTTP"
        tags["span.kind"] = "client"
        serializedInvocation["tags"] = tags
        spanContext["id"] = self.id
        spanContext["traceId"] = self.traceId
        spanContext["parentId"] = self.parentId
        serializedInvocation["spanContext"] = spanContext
        return serializedInvocation
        
    }
    
}
