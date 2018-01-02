//
//  InvocationMapper.swift
//  AutomaticInvocationTracker
//
//  Created by Matteo Sassano on 15.05.17.
//  Copyright © 2017 Matteo Sassano. All rights reserved.
//

import UIKit

public class IITMSpanOrganizer: NSObject {
    
    var oldBuffer : [UInt : [IITMInvocation]]?
    var newBuffer : [UInt : [IITMInvocation]]?
    
    var oldBufferMessages : [UInt : [String]]?
    var newBufferMessages : [UInt : [String]]?
    
    var closedTraces : [UInt64: [IITMInvocation]]?
    var closedTracesMessages : [UInt64: [String]]?
    
    var messageUtil: IITMMessageUtil?
    var remoteMessageUtil: IITMRemoteMessageUtil?
    
    var symbolMapper: IITMSymbolMapper
    
    var doneRemotecalls: [IITMRemoteCall]?
    var doneRemotecallsMessages: [String]?
    
    public enum IITMDataModel {
        case message
        case instance
        case remoteCallInstanceOnly
    }
    
    public enum IITMDispatchStrategy {
        case closeTrace
        case singleSpan
        case periodic
    }
    
    var dataModel: IITMSpanOrganizer.IITMDataModel
    var dispatchStrategy: IITMSpanOrganizer.IITMDispatchStrategy
    
    override convenience init() {
        self.init(model: .instance)
    }
    
    init(model: IITMDataModel) {
        dataModel = model
        dispatchStrategy = .closeTrace
        symbolMapper = IITMSymbolMapper()
        super.init()
        initializeBuffer()
    }
    
    func initializeBuffer() {
        switch dataModel {
        case .message:
            oldBufferMessages = [UInt : [String]]()
            newBufferMessages = [UInt : [String]]()
            doneRemotecallsMessages = [String]()
            remoteMessageUtil = IITMRemoteMessageUtil()
        case .instance:
            oldBuffer = [UInt : [IITMInvocation]]()
            newBuffer = [UInt : [IITMInvocation]]()
            closedTraces = [UInt64 : [IITMInvocation]]()
            doneRemotecalls = [IITMRemoteCall]()
        case .remoteCallInstanceOnly:
            oldBufferMessages = [UInt : [String]]()
            newBufferMessages = [UInt : [String]]()
            doneRemotecalls = [IITMRemoteCall]()
        }
        
    }
    
    func cleanBuffer() {
        oldBufferMessages = nil
        newBufferMessages = nil
        closedTraces = nil
        oldBuffer = nil
        newBuffer = nil
        closedTracesMessages = nil
        doneRemotecalls = nil
        doneRemotecallsMessages = nil
    }
    
    func cleanUtilities() {
        messageUtil = nil
        remoteMessageUtil = nil
    }
    
    func createSpanStack(symbols: [String]) {
        var spans = [IITMInvocation]()
        var threadId: UInt
        for symbol in symbols {
            if !ignoredSymbol(symbol: symbol) {
                let span = symbolMapper.mapSymbolToSpan(symbol: symbol)
                // print(span.name)
                spans.append(span)
            }
        }
        threadId = getThreadID()
        if oldBuffer?[threadId] == nil || oldBuffer?[threadId]?.count == 0 {
            oldBuffer?[threadId] = spans
            correlateSpans(threadId: threadId)
        } else {
            newBuffer?[threadId] = spans
            compareStacks(threadId: threadId)
            updateBuffer(threadId: threadId)
            correlateSpans(threadId: threadId)
            
        }
        
    }
    
    func getThreadID() -> UInt {
        let threadDescription = Thread.current.description
        var s = threadDescription.components(separatedBy: "number = ")
        var s1 = s[1].components(separatedBy: ", name = ")
        return UInt(s1[0])!
    }
    
    func ignoredSymbol(symbol: String) -> Bool {
        if symbol.contains("GlobalLockRelease") {
            return true
        }
        if symbol.contains("viewDidLoad") {
            return true
        }
        if symbol.contains("UIEventFetcher") {
            return true
        }
        if symbol.contains("CFRunLoop") {
            return true
        }
        if symbol.contains("siginfo") {
            return true
        }
        if symbol.contains("sigtramp") {
            return true
        }
        if symbol.contains("sigtramp") {
            return true
        }
        if symbol.contains("???") {
            return true
        }
        if symbol.contains("pthread") {
            return true
        }
        if symbol.contains("thread_start") {
            return true
        }
        if symbol.contains("__NSThread__start__") {
            return true
        }
        if symbol.contains("_TTRXFo___XFdCb___") {
            return true
        }
        if symbol.contains("main") {
            return true
        }
        if symbol.contains("NSRunLoop") {
            return true
        }
        if symbol.contains("sidetable_release") {
            return true
        }
        if symbol.contains("nano_malloc_check_clear") {
            return true
        }
        return false
    }
    
    func compareStacks(threadId: UInt) {
        for (index, _) in (oldBuffer?[threadId]?.enumerated())! {
            if (newBuffer?[threadId]?.count)! > index {
                if oldBuffer?[threadId]?[index].name == newBuffer?[threadId]?[index].name {
                    adjustSpan(index: index, threadId: threadId)
                } else {
                    let span = oldBuffer?[threadId]?[index]
                    span?.closeInvocation()
                    addCompleteSpanToBuffer(span: span!)
                }
            } else {
                let span = oldBuffer?[threadId]?[index]
                span?.closeInvocation()
                addCompleteSpanToBuffer(span: span!)
            }
        }
        
        
        
        /*
        for (index, _) in (oldBuffer?[threadId]?.enumerated())! {
            if (newBuffer?[threadId]?.count)! > index {
                if oldBuffer?[threadId]?[index].name == newBuffer?[threadId]?[index].name {
                    adjustSpan(index: index, threadId: threadId)
                } else {
                    let span = oldBuffer?[threadId]?[index]
                    span?.closeInvocation()
                    if index > 0 {
                        setRelation(child: span!, parent: (oldBuffer?[threadId]?[index - 1])!)
                    } else {
                        setRoot(span: span!)
                    }
                    addCompleteSpanToBuffer(span: span!)
                }
            } else {
                let span = oldBuffer?[threadId]?[index]
                span?.closeInvocation()
                if index > 0 {
                    setRelation(child: span!, parent: (oldBuffer?[threadId]?[index - 1])!)
                } else {
                    setRoot(span: span!)
                }
                addCompleteSpanToBuffer(span: span!)
            }
        }
        
        correlateNewSpans(threadId: threadId)
        
        if (newBuffer?[threadId]?.count)! < (oldBuffer?[threadId]?.count)! {
            
            for (index, _) in (oldBuffer?[threadId]?.reversed().enumerated())! {
                if index < (oldBuffer?[threadId]?.count)! - (newBuffer?[threadId]?.count)! {
                let span = oldBuffer?[threadId]?[index]
                span?.closeInvocation()
                if index != (oldBuffer?[threadId]?.count)! - 1 {
                    setRelation(child: (oldBuffer?[threadId]?[index + 1])!, parent: span!)
                } else {
                    setRoot(span: span!)
                }
                addCompleteSpanToBuffer(span: span!)
                }
            }
        }
 */
        
        
        
    }
    
    func correlateSpans(threadId: UInt) {
        for (index, _) in (oldBuffer?[threadId]?.enumerated())! {
            if index == 0 {
                setRoot(span: (oldBuffer?[threadId]?[index])!)
            } else {
                setRelation(child: (oldBuffer?[threadId]?[index])!, parent: (oldBuffer?[threadId]?[index - 1])!)
            }
        }
    }
    
    func correlateNewSpans(threadId: UInt) {
        if (newBuffer?.count)! > (oldBuffer?.count)! {
            let uncorrelatedIndex = oldBuffer?.count
            for index in (uncorrelatedIndex!)...((newBuffer?.count)! - 1) {
                let span = newBuffer?[threadId]?[index]
                if index > 0 {
                    setRelation(child: span!, parent: (newBuffer?[threadId]?[index - 1])!)
                } else {
                    setRoot(span: span!)
                }
            }
        }
    }
    
    func adjustSpan(index: Int, threadId: UInt) {
        newBuffer?[threadId]?[index] = (oldBuffer?[threadId]?[index])!
    }
    
    func updateBuffer(threadId: UInt) {
        oldBuffer?[threadId] = newBuffer?[threadId]
    }
    
    func addRemotecall(remotecall: IITMRemoteCall) {
        switch dataModel {
        case .instance:
            doneRemotecalls?.append(remotecall)
            break
        case .remoteCallInstanceOnly:
            doneRemotecalls?.append(remotecall)
            break
        case .message:
            let remotecallMessage = remoteMessageUtil?.getRemoteCall(remotecall: remotecall)
            doneRemotecallsMessages?.append(remotecallMessage!)
            break
        }
        
    }
    
    
    func addCompleteSpanToBuffer(span: IITMInvocation) {
        switch dataModel {
        case .instance:
            if (closedTraces?[span.traceId]) != nil {
                closedTraces?[span.traceId]?.append(span)
            } else {
                closedTraces?[span.traceId] = [IITMInvocation]()
                closedTraces?[span.traceId]?.append(span)
            }
            break
            
        default:
            let spanMessage = messageUtil?.completeSpanString(span: span)
            if (closedTracesMessages?[span.traceId]) != nil {
                closedTracesMessages?[span.traceId]?.append(spanMessage!)
            } else {
                closedTracesMessages?[span.traceId] = [String]()
                closedTracesMessages?[span.traceId]?.append(spanMessage!)
            }
            break
        }
        
        if dispatchStrategy == .singleSpan {
            IITMAgent.getInstance().spansDispatch()
        } else if dispatchStrategy == .closeTrace {
            if isRoot(span: span) {
                IITMAgent.getInstance().spansDispatch()
            }
        }
        
    }
    
    func addCompleteSpanMessageToBuffer(spanMessage: String) {
        if var trace = closedTracesMessages?[(messageUtil?.getTraceId(span: spanMessage))!] {
            trace.append(spanMessage)
        } else {
            closedTracesMessages?[(messageUtil?.getTraceId(span: spanMessage))!] = [String]()
            closedTracesMessages?[(messageUtil?.getTraceId(span: spanMessage))!]?.append(spanMessage)
        }
    }
    
    
    func setRelation(child: IITMInvocation, parent: IITMInvocation) {
        child.parentId = parent.id
        child.traceId = parent.traceId
    }
    
    func setRelationFromMessage(child: IITMInvocation, parent: String) {
        if messageUtil != nil {
            child.parentId = (messageUtil?.getId(span: parent))!
            child.traceId = (messageUtil?.getTraceId(span: parent))!
        }
    }
    
    func setRoot(span: IITMInvocation) {
        span.parentId = UInt64(span.id)
        span.traceId = UInt64(span.id)
    }
    
    func isRoot(span: IITMInvocation) -> Bool {
        return span.id == span.parentId && span.id == span.traceId
    }
    
    
    func getSpanMessage(span: IITMInvocation) -> String {
        if messageUtil != nil {
            if let spanstring = messageUtil?.getSpanString(span: span) {
                return spanstring
            }
        }
        return "error span"
    }
    
}
