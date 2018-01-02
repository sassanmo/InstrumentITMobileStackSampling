
import UIKit
import Foundation
import SystemConfiguration
import CoreTelephony


class IITMNetworkReachability: NSObject {
    
    private static var defaultRoute : SCNetworkReachability!
    override init() {
        var za = sockaddr_in()
        bzero(&za, MemoryLayout.size(ofValue: za))
        za.sin_len =  UInt8(MemoryLayout.size(ofValue: za))
        za.sin_family = sa_family_t(AF_INET)
        
        IITMNetworkReachability.defaultRoute = withUnsafePointer(to: &za) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1, {address in
                SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, address)
            })
        }
    }
    
    class func getConnectionInformation() -> (String, String) {
        var flags : SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if !SCNetworkReachabilityGetFlags(IITMNetworkReachability.defaultRoute, &flags) {
            return ("", "")
        }
        
        if flags == SCNetworkReachabilityFlags.isWWAN {
            let networkInfo = CTTelephonyNetworkInfo()
            var carrierName : String = ""
            if let c = networkInfo.subscriberCellularProvider?.carrierName {
                carrierName = c
            }
            let carrierType = networkInfo.currentRadioAccessTechnology
            switch carrierType{
            case CTRadioAccessTechnologyGPRS?,CTRadioAccessTechnologyEdge?,CTRadioAccessTechnologyCDMA1x?:
                return ("2G", carrierName)
            case CTRadioAccessTechnologyWCDMA?,CTRadioAccessTechnologyHSDPA?,CTRadioAccessTechnologyHSUPA?,CTRadioAccessTechnologyCDMAEVDORev0?,CTRadioAccessTechnologyCDMAEVDORevA?,CTRadioAccessTechnologyCDMAEVDORevB?,CTRadioAccessTechnologyeHRPD?:
                return ("3G", carrierName)
            case CTRadioAccessTechnologyLTE?:
                return ("4G", carrierName)
            default:
                return ("", carrierName)
            }
        } else if flags == SCNetworkReachabilityFlags.reachable {
            return ("WLAN", "")
        }
        return ("", "")
    }
}
