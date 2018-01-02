//
//  MetricsController.swift
//  AutomaticInvocationTracker
//
//  Created by Matteo Sassano on 15.05.17.
//  Copyright © 2017 Matteo Sassano. All rights reserved.
//

import UIKit

class IITMMetricsController: NSObject {
    
    var nativeRessources : native_diagnostic_info_t
    
    var timestampList : [UInt64]
    var measurementMapList : [[String : Any]]
    
    var timer : Timer
    let bufferSize : Int = 10
    var fireTimeIntervall : Float = 1
    
    override init() {
        nativeRessources = native_diagnostic_info_t()
        timer = Timer()
        timestampList = [UInt64]()
        measurementMapList = [[String : Any]]()
        super.init()
        self.reinitializeTimer()
    }
    
    func changeTimerIntervall(seconds: Float) {
        self.fireTimeIntervall = seconds
    }
    
    func getCpuUsage() -> Float {
        if getCPULoad(&nativeRessources.cpuusage) == 0 {
            return nativeRessources.cpuusage
        } else {
            return -1.0;
        }
    }
    
    func getResidentalMemorySize() -> UInt64 {
        getMemoryUsage(&nativeRessources.memory.memory_info)
        return nativeRessources.memory.memory_info.rss
    }
    
    func getVirtualMemorySize() -> UInt64 {
        getMemoryUsage(&nativeRessources.memory.memory_info)
        return nativeRessources.memory.memory_info.vs
    }
    
    func getMemoryLoad() -> Float {
        return 1.0 - (Float(getFreeMemory()) / Float(ProcessInfo.processInfo.physicalMemory))
    }
    
    func getMemorySize() -> UInt64 {
        return UInt64(getResidentMemory())
    }
    
    func getFreeMem() -> Int64 {
        return getFreeMemory()
    }
    
    func getDataInSpecificIntervall() {
        self.performMeasurements()
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.fireTimeIntervall), target: self, selector: #selector(self.performMeasurements), userInfo: nil, repeats: true);
    }
    
    func reinitializeTimer() {
        DispatchQueue.main.async(execute: {
            self.timer.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.fireTimeIntervall), target: self, selector: #selector(self.performMeasurements), userInfo: nil, repeats: true);
        })
    }
    
    func invalidateTimer() {
        self.timer.invalidate()
    }
    
    @objc func performMeasurements() {
        if (IITMAgent.getInstance().optOut) {
            self.timer.invalidate()
        }
        
        let timestamp = getTimestamp()
        
        var measurementMap = [String : Any]()
        measurementMap["storageUsage"] = IITMDiskMetric.getUsedDiskPercentage()
        measurementMap["batteryPower"] = IITMBatteryLevel.getBatteryLevel()
        measurementMap["timestamp"] = timestamp
        measurementMap["type"] = "MobilePeriodicMeasurement"
        measurementMap["cpuUsage"] = getCpuUsage()
        measurementMap["memoryUsage"] = getMemoryLoad()
        
        if (measurementMapList.count >= bufferSize) {
            measurementMapList.remove(at: 0)
            timestampList.remove(at: 0)
        }
        
        measurementMapList.append(measurementMap)
        timestampList.append(timestamp)
        
        if IITMAgent.getInstance().invocationOrganizer.dispatchStrategy == .periodic {
            IITMAgent.getInstance().spansDispatch()
        }
    }

}
