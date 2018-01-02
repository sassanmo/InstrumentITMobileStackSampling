//
//  InvocationSerializer.swift
//  AutomaticInvocationTracker
//
//  Created by Matteo Sassano on 15.05.17.
//  Copyright © 2017 Matteo Sassano. All rights reserved.
//

import UIKit

class IITMInvocationSerializer: NSObject {
    
    var invocationOrganizer : IITMSpanOrganizer
    var metricsController : IITMMetricsController
    var serializedMeasurements : [String]
    
    init(invocationOrganizer: IITMSpanOrganizer, metricsConroller: IITMMetricsController) {
        self.serializedMeasurements = [String]()
        self.invocationOrganizer = invocationOrganizer
        self.metricsController = metricsConroller
    }
    
    func getDataPackage() {
        var jsonObject = [String : Any]()
        jsonObject["deviceID"] = IITMAgent.getInstance().agentId
        jsonObject["spans"] = getInvocations()
        jsonObject["measurements"] = getMeasurements()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonString : String = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            print(jsonString)
            serializedMeasurements.append(jsonString)
        } catch {
            print(error)
        }
    }
    
    func serializeInvocation(invocation : IITMInvocation) -> [String : Any] {
        return invocation.getInvocationMap()
    }
    
    func serializeInvocationFromMessage(invocation: String) -> [String : Any] {
        
        return IITMMessageUtil().convertToJson(span: invocation)
    }
    
    func serializeRemotecallFromMessage(remotecall: String) -> [String : Any] {
        
        return IITMRemoteMessageUtil().convertToJson(span: remotecall)
    }
    
    func getMeasurements() -> [[String : Any]] {
        var measurements = [[String : Any]]()
        for measurement in metricsController.measurementMapList {
            let measurementObject = measurement
            measurements.append(measurementObject)
        }
        metricsController.measurementMapList = [[String : Any]]()
        return measurements
    }
    
    func getInvocations() -> [[String : Any]] {
        var invocations = [[String : Any]]()
        if IITMAgent.getInstance().invocationOrganizer.dataModel == .instance {
            if let closedtraces = invocationOrganizer.closedTraces {
                for (_, value) in closedtraces {
                    for invocation in value {
                        let invocationObject = serializeInvocation(invocation: invocation)
                        invocations.append(invocationObject)
                    }
                }
            }
            invocationOrganizer.closedTraces = [UInt64: [IITMInvocation]]()
        } else {
            if let closedtraces = invocationOrganizer.closedTracesMessages {
                for (_, value) in closedtraces {
                    for invocation in value {
                        let invocationObject = serializeInvocationFromMessage(invocation: invocation)
                        invocations.append(invocationObject)
                    }
                }
            }
        }
        if IITMAgent.getInstance().invocationOrganizer.dataModel == .message {
            if let remoteCalls = invocationOrganizer.doneRemotecallsMessages {
                for remotecall in remoteCalls {
                    let invocationObject = serializeRemotecallFromMessage(remotecall: remotecall)
                    invocations.append(invocationObject)
                }
            }
        } else {
            if let remoteCalls = invocationOrganizer.doneRemotecalls {
                for remotecall in remoteCalls {
                    let invocationObject = serializeInvocation(invocation: remotecall)
                    invocations.append(invocationObject)
                }
            }
        }
        
        invocationOrganizer.doneRemotecalls = [IITMRemoteCall]()
        return invocations
    }
    
}
