//
//  IITMSCTimerController.swift
//  IITMCSCallstackSampling
//
//  Created by NovaTec on 07.09.17.
//  Copyright © 2017 NovaTec. All rights reserved.
//

import UIKit

class IITMTimerController: NSObject {
    
    var timer : Timer
    
    // Time period in seconds
    var period = 1.0
    
    // Default time period in seconds
    static let DEFAULT_PERIOD = 1.0
    
    var threadController = IITMThreadController()
    
    
    override init() {
        timer = Timer()
    }
    
    func initializeTimer(t: TimeInterval = DEFAULT_PERIOD) {
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(t), target: self, selector: #selector(self.performSampling), userInfo: nil, repeats: true)
        
    }
    
    func performSampling() {
        //threadController.fetchThreads()
    }

}
