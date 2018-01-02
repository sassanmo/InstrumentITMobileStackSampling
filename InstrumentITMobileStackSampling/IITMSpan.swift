//
//  IITMSpan.swift
//  InstrumentITMobileIOSTracing
//
//  Created by NovaTec on 05.10.17.
//  Copyright © 2017 NovaTec. All rights reserved.
//

import UIKit

public class IITMSpan: NSObject {
    
    var id : UInt64
    
    var parentId : UInt64
    
    var traceId : UInt64
    
    var duration : UInt64?
    
    var startTime : UInt64?
    
    var endTime : UInt64?
    
    var ended : Bool = false
    
    override init() {
        self.id = calculateUuid()
        self.parentId = id
        self.traceId = id
    }

}
