
import Foundation
import SystemConfiguration.CaptiveNetwork

public class IITMSSIDSniffer  {

    class func getSSID() -> String? {
        /* Note: 
            CNCopySupportedInterfaces returns nil while running on the emulator 
         */
        let interfaces = CNCopySupportedInterfaces()
        if(interfaces == nil) {
            return "NO SSID"
        }
        
        let interfaceArray = interfaces as! [String]
        if interfaceArray.count < 1 {
            return "NO SSID"
        }
        
        let interfaceName = interfaceArray[0] as String
        let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName as CFString)
        if(unsafeInterfaceData == nil) {
            return "NO SSID"
        }
        
        let interfaceData = unsafeInterfaceData as! Dictionary<String, AnyObject>
        return interfaceData["SSID"] as? String
    }
}
