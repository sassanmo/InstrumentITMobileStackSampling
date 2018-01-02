//
//  Invocation.swift
//  AutomaticInvocationTracker
//
//  Created by Matteo Sassano on 15.05.17.
//  Copyright © 2017 Matteo Sassano. All rights reserved.
//


import Foundation

public class IITMInvocation: IITMSpan {
    
    /// Defines the name of the callable function
    var name : String
    
    /// Describes the object/class holding the method
    var holder : String?
    
    var threadName : String
    
    var threadId : UInt
    
    
    
    init(name: String) {
        self.name = name
        self.holder = "noholder"
        
        let threadDescription = Thread.current.description
        var s = threadDescription.components(separatedBy: "number = ")
        var s1 = s[1].components(separatedBy: ", name = ")
        self.threadId = UInt(s1[0])!
        var s2 = s1[1].components(separatedBy: "}")
        self.threadName = s2[0]
        
        super.init()
        self.startTime = getTimestamp()
    }
    
    init(name: String, holder: String) {
        //super.init()
        self.name = name
        self.holder = holder
        
        let threadDescription = Thread.current.description
        var s = threadDescription.components(separatedBy: "number = ")
        var s1 = s[1].components(separatedBy: ", name = ")
        self.threadId = UInt(s1[0])!
        var s2 = s1[1].components(separatedBy: "}")
        self.threadName = s2[0]
        
        super.init()
        self.startTime = getTimestamp()
    }
    
    func closeInvocation() {
        self.ended = true
        self.endTime = getTimestamp()
        if let endtime = self.endTime, let starttime = self.startTime {
            self.duration = endtime - starttime
        }
    }

    func setInvocationRelation(parent: inout IITMInvocation) {
        self.parentId = parent.id
        self.traceId = parent.traceId
    }
    
    func setInvocationRelation(parent: inout IITMRemoteCall) {
        self.parentId = parent.id
        self.traceId = parent.traceId
    }
    
    
    func setInvocationAsRoot() {
        self.traceId = self.id
        self.parentId = self.id
    }
    
    func getThreadProperties() -> (UInt, String) {
        let threadDescription = Thread.current.description
        var s = threadDescription.components(separatedBy: "number = ")
        var s1 = s[1].components(separatedBy: ", name = ")
        let threadId = UInt(s1[0])
        var s2 = s1[1].components(separatedBy: "}")
        let threadName = s2[0]
        return (threadId!, threadName)
    }
    
    func getInvocationMap() -> [String : Any] {
        var serializedInvocation: [String : Any] = [String : Any]()
        var tags: [String : Any] = [String : Any]()
        var spanContext: [String : Any] = [String : Any]()
        serializedInvocation["operationName"] = self.name
        serializedInvocation["startTimeMicros"] = self.startTime
        serializedInvocation["duration"] = self.duration
        tags["span.kind"] = "client"
        tags["ext.propagation.type"] = "IOS"
        serializedInvocation["tags"] = tags
        spanContext["id"] = self.id
        spanContext["traceId"] = self.traceId
        spanContext["parentId"] = self.parentId
        serializedInvocation["spanContext"] = spanContext
        return serializedInvocation
    }
    
    override public var description: String {
        return "\(String(describing: holder)).\(name)"
    }
    
}

