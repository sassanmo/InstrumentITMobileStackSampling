//
//  IITMSCAgent.swift
//  IITMCSCallstackSampling
//
//  Created by NovaTec on 07.09.17.
//  Copyright © 2017 NovaTec. All rights reserved.
//

import UIKit

public class IITMAgent: NSObject {
    
    var agentId: UInt64 = 0
    
    static var agent: IITMAgent?
    // var timerController: IITMSCTimerController
    var collectionThread: IITMCollectionThread
    
    var invocationOrganizer: IITMSpanOrganizer
    
    var locationHandler: IITMLocationHandler?
    
    var networkReachability: IITMNetworkReachability?
    
    var dataStorage: IITMDataStorage
    
    var invocationSerializer: IITMInvocationSerializer
    
    /// Collects device Infromation in a specific time interval
    var metricsConrtoller: IITMMetricsController
    
    var restManager: IITMRestManager
    
    var optOut: Bool = false
    
    var dispatchAlways: Bool = true
    
    override init() {
        
        invocationOrganizer = IITMSpanOrganizer()
        dataStorage = IITMDataStorage()
        metricsConrtoller = IITMMetricsController()
        invocationSerializer = IITMInvocationSerializer(invocationOrganizer: invocationOrganizer, metricsConroller: metricsConrtoller)
        restManager = IITMRestManager()
        collectionThread = IITMCollectionThread()
        locationHandler = IITMLocationHandler()
        networkReachability = IITMNetworkReachability()
        
        super.init()
        
        loadAgentId()
        IITMAgent.agent = self
        locationHandler?.requestLocationAuthorization()
    }
    
    public static func getInstance() -> IITMAgent {
        if let agent = IITMAgent.agent {
            return agent
        } else {
            return IITMAgent()
        }
    }
    
    public static func reinitAgent() {
        IITMAgent.agent = IITMAgent()
    }
    
    public func startAgent(period: Double = IITMTimerController.DEFAULT_PERIOD) {
        //timerController.initializeTimer(t: period)
        self.collectionThread.startCollection(period: period)
    }
    
    public func changeDispatch(strategy: IITMSpanOrganizer.IITMDispatchStrategy) {
        invocationOrganizer.dispatchStrategy = strategy
    }
    
    public func allowDispatch(with mobiledata: Bool) {
        dispatchAlways = mobiledata
    }
    
    public func trackRemoteCall(function: String = #function, file: String = #file, url: String) -> IITMRemoteCall? {
        if (self.optOut == false) {
            let remotecall = IITMRemoteCall(name: function, holder: file, url: url)
            setRemoteCallStartProperties(remotecall: remotecall)
            // invocationOrganizer.correlateRemotecall(remotecall: remotecall)
            return remotecall
        } else {
            return nil
        }
    }
    
    public func closeRemoteCall(remotecall: IITMRemoteCall, response: URLResponse?, error: Error?) {
        if (self.optOut == false) {
            setRemoteCallEndProperties(remotecall: remotecall)
            remotecall.closeRemoteCall(response: response, error: error)
            invocationOrganizer.addRemotecall(remotecall: remotecall)
            spansDispatch()
        }
    }
    
    func injectHeaderAttributes(remotecall: IITMRemoteCall, request: inout NSMutableURLRequest) {
        if (self.optOut == false) {
            let spanid = remotecall.id
            let traceId = remotecall.traceId
            request.addValue(decimalToHex(decimal: spanid), forHTTPHeaderField: "x-inspectit-spanid")
            request.addValue(decimalToHex(decimal: traceId), forHTTPHeaderField: "x-inspectit-traceid")
        }
    }
    
    private func setRemoteCallStartProperties(remotecall: IITMRemoteCall) {
        remotecall.startPosition = locationHandler?.getUsersPosition()
        remotecall.startSSID = IITMSSIDSniffer.getSSID()
        remotecall.startConnectivity = IITMNetworkReachability.getConnectionInformation().0
        remotecall.startProvider = IITMNetworkReachability.getConnectionInformation().1
    }
    
    private func setRemoteCallEndProperties(remotecall: IITMRemoteCall) {
        remotecall.endPosition = locationHandler?.getUsersPosition()
        remotecall.endSSID = IITMSSIDSniffer.getSSID()
        remotecall.endConnectivity = IITMNetworkReachability.getConnectionInformation().0
        remotecall.endProvider = IITMNetworkReachability.getConnectionInformation().1
    }

    
    func spansDispatch() {
        if dispatchAlways || IITMNetworkReachability.getConnectionInformation().0 != "WLAN" {
            
            switch invocationOrganizer.dataModel {
            case .instance:
                if invocationOrganizer.closedTraces?.count != 0 || invocationOrganizer.doneRemotecalls?.count != 0 {
                    invocationSerializer.getDataPackage()
                }
            default:
                if invocationOrganizer.closedTracesMessages?.count != 0 {
                    invocationSerializer.getDataPackage()
                }
            }
            
            if invocationSerializer.serializedMeasurements.count != 0 {
                var invocationBuffer = invocationSerializer.serializedMeasurements
                invocationSerializer.serializedMeasurements = [String]()
                for (index, item) in invocationBuffer.enumerated() {
                    print(item)
                    restManager.httpPostRequest(path: IITMAgentConstants.HOST, body: item, completion: { error -> Void in
                        if error {
                            self.invocationSerializer.serializedMeasurements.append(item)
                        } else {
                            print(item)
                            invocationBuffer.remove(at: index)
                        }
                    })
                }
                
            }
        }
    }
    
    /// Loads the Agent ID whitch will be created once
    /// If not any stored than a new ID will be created
    func loadAgentId(){
        if let agentid = dataStorage.loadAgentId() {
            self.agentId = agentid
        } else {
            self.agentId = generateAgentId()
            self.dataStorage.storeAgentId(id: self.agentId)
        }
    }
    
    func generateAgentId() -> UInt64 {
        return calculateUuid()
    }
    
    

}
