

import UIKit
import CoreLocation

class IITMLocationHandler {
    
    let locationManager = CLLocationManager()
    var rootViewController : CLLocationManagerDelegate?
    var locationUpdateStarted = false
    
    init() {
        let appDelegate  = UIApplication.shared.delegate!
        var appwindow: UIWindow? = appDelegate.window!
        guard (appwindow != nil) else {
            appwindow = UIWindow(frame: UIScreen.main.bounds)
            return
        }
        if let locationManagerDelegate = appwindow?.rootViewController as? CLLocationManagerDelegate {
            rootViewController = locationManagerDelegate
        }
        locationManager.delegate = rootViewController
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func requestLocationAuthorization() {
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func getUsersCurrentLatitudeAndLongitude() -> (CLLocationDegrees, CLLocationDegrees) {
        if CLLocationManager.locationServicesEnabled() && (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            if (locationUpdateStarted == false) {
                locationManager.startUpdatingLocation()
                locationUpdateStarted = true
            }
            let locValue : CLLocationCoordinate2D = locationManager.location!.coordinate
            return (locValue.latitude, locValue.longitude)
        }
        return (CLLocationDegrees(), CLLocationDegrees())
    }
    
    func getUsersPosition() -> CLLocationCoordinate2D? {
        if CLLocationManager.locationServicesEnabled() && (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            if (locationUpdateStarted == false) {
                locationManager.startUpdatingLocation()
                locationUpdateStarted = true
            }
            let position : CLLocationCoordinate2D = locationManager.location!.coordinate
            return position
        }
        return nil
    }
}
