//
//  IITMSCCollectionThread.swift
//  IITMCSCallstackSampling
//
//  Created by NovaTec on 07.09.17.
//  Copyright © 2017 NovaTec. All rights reserved.
//

import UIKit

class IITMCollectionThread: NSObject {
    
    var thread: Thread?
    
    static var callingThread: pthread_t?
    
    static var LOOP_CONTIDION = true
    
    // Time period in seconds
    static var PERIOD = 1.0
    
    // Default time period in seconds
    static let DEFAULT_PERIOD = 1.0
    
    
    func startCollection(period: Double) {
        
        IITMCollectionThread.PERIOD = period
        thread = Thread(block: {
            let threadController = IITMThreadController()
            var lowestTime: UInt64 = UINT64_MAX
            var highestTime: UInt64 = 0
            Calling_Thread = pthread_self()
            print("START: \(pthread_self())")
            while IITMCollectionThread.LOOP_CONTIDION {
                let start = getTimestamp()
                
                let threads = threadController.fetchThreads()
                
                for var t in threads {
                    threadController.setSignal(pthread: &t)
                    //let a = UnsafeMutablePointer<UnsafeMutableRawPointer>
                    //GetCallstack(t, pthread_get_stackaddr_np(t), pthread_get_stacksize_np(t))
                }
                let duration = getTimestamp() - start
                
                if duration < lowestTime {
                    lowestTime = duration
                }
                if duration > highestTime {
                    highestTime = duration
                }
                print("highest TIME COllection: \(highestTime)")
                print("lowest TIME COllection: \(lowestTime)")
                Thread.sleep(forTimeInterval: IITMCollectionThread.PERIOD)
            
            }
            
            if !IITMCollectionThread.LOOP_CONTIDION {
                 self.thread = nil
            }
        })
    
         thread?.start()
    }
    
    func stopCollection() {
        if thread != nil {
            IITMCollectionThread.LOOP_CONTIDION = false
        }
    }
    
    static func changeTimeInterval(period: Double) {
        IITMCollectionThread.PERIOD = period
    }
    
    static func setLoopCondition(newCondition: Bool) {
        IITMCollectionThread.LOOP_CONTIDION = newCondition
    }
    
    

}
