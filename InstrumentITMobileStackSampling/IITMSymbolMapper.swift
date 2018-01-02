//
//  IITMSymbolMapper.swift
//  InstrumentITMobileStackSampling
//
//  Created by NovaTec on 13.10.17.
//  Copyright © 2017 NovaTec. All rights reserved.
//

import UIKit

class IITMSymbolMapper: NSObject {
    
    func mapSymbolToSpan(symbol: String) -> IITMInvocation {
        var symbolSplits = symbol.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        let symbolCondensed = symbolSplits.filter { !$0.isEmpty }.joined(separator: " ")
        symbolSplits = symbolCondensed.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        let span = IITMInvocation(name: symbolSplits[3])
        return span
    }

}
