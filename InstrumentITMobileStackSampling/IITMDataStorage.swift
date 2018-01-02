
import UIKit

class IITMDataStorage: NSObject {
    
    let storagePath = "storage"
    let optOutPath = "optOut"
    let agentIdStorage = "agentIDStorage"
    let hostStorage = "hostStorage"
    let monitorStorage = "monitorStorage"
    

    func loadUsecases() -> [String] {
        if let encodedObj = UserDefaults.standard.object(forKey: storagePath) as? NSData {
            if let loadedData = NSKeyedUnarchiver.unarchiveObject(with: encodedObj as Data) as? [String] {
                return loadedData
            }
        }
        return []
    }
    
    func storeHostUrl(url: String) {
        let encodedObj = NSKeyedArchiver.archivedData(withRootObject: url)
        UserDefaults.standard.set(encodedObj, forKey: hostStorage)
    }
    
    func loadHostUrl() -> String? {
        if let encodedObj = UserDefaults.standard.object(forKey: hostStorage) as? NSData {
            if let loadedData = NSKeyedUnarchiver.unarchiveObject(with: encodedObj as Data) as? String {
                return loadedData
            }
        }
        return nil
    }
    
    func storeMonitorUrl(url: String) {
        let encodedObj = NSKeyedArchiver.archivedData(withRootObject: url)
        UserDefaults.standard.set(encodedObj, forKey: monitorStorage)
    }
    
    func loadMonitorUrl() -> String? {
        if let encodedObj = UserDefaults.standard.object(forKey: monitorStorage) as? NSData {
            if let loadedData = NSKeyedUnarchiver.unarchiveObject(with: encodedObj as Data) as? String {
                return loadedData
            }
        }
        return nil
    }
    
    func storeAgentId(id: UInt64) {
        let encodedObj = NSKeyedArchiver.archivedData(withRootObject: id)
        UserDefaults.standard.set(encodedObj, forKey: agentIdStorage)
    }
    
    func loadAgentId() -> UInt64? {
        if let encodedObj = UserDefaults.standard.object(forKey: agentIdStorage) as? NSData {
            if let loadedData = NSKeyedUnarchiver.unarchiveObject(with: encodedObj as Data) as? UInt64 {
                return loadedData
            }
        }
        return nil
    }
    
    func storeUsecases(storageData: [String]) {
        let encodedObj = NSKeyedArchiver.archivedData(withRootObject: storageData)
        UserDefaults.standard.set(encodedObj, forKey: storagePath)
    }
    
    func clearStorage() {
        let encodedObj = NSKeyedArchiver.archivedData(withRootObject: [])
        UserDefaults.standard.set(encodedObj, forKey: storagePath)
    }
    
}
