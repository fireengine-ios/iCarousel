//
//  LocationManager.swift
//  Depo_LifeTech
//
//  Created by Oleg on 05.10.17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private static var uniqueInstance: LocationManager?
    
    private let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        configurateLocationManager()
    }
    
    private func configurateLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100 //kCLDistanceFilterNone - any changes
        locationManager.pausesLocationUpdatesAutomatically = false
        
    }
    
    @objc static func shared() -> LocationManager {
        if uniqueInstance == nil {
            uniqueInstance = LocationManager()
        }
        return uniqueInstance!
    }
    
    func checkDoWeNeedShowLocationPermissionAllert(yesWeNeed:@escaping (() -> Void)){
        SingletonStorage.shared.getUniqueUserID(success: { (uniqueUserID) in
            let key = uniqueUserID + "locationPermission"
            let permission = UserDefaults.standard.integer(forKey: key)
            if permission == 0{
                UserDefaults.standard.set(1, forKey: key)
                UserDefaults.standard.synchronize()
                yesWeNeed()
            }
        }) {
            
        }
    }
    
    func startUpdateLocation(){
        if CLLocationManager.locationServicesEnabled(){
            if CLLocationManager.authorizationStatus() == .notDetermined{
                locationManager.requestAlwaysAuthorization()
            } else {
                locationManager.startMonitoringSignificantLocationChanges()
                if #available(iOS 9.0, *) {
                    locationManager.allowsBackgroundLocationUpdates = true
                }
                locationManager.startUpdatingLocation()
            }
        }else{
            checkDoWeNeedShowLocationPermissionAllert(yesWeNeed: {
                let controller = UIAlertController.init(title: "", message: TextConstants.locationServiceDisable , preferredStyle: .alert)
                let okAction = UIAlertAction(title: TextConstants.ok, style: .default, handler: { (action) in
                    UIApplication.shared.openSettings()
                })
                let cancelAction = UIAlertAction(title: TextConstants.cancel , style: .cancel, handler: { (action) in
                    
                })
                controller.addAction(okAction)
                controller.addAction(cancelAction)
                RouterVC().presentViewController(controller: controller)
            })
        }
    }
 
    func stopUpdateLocation(){
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    // CLLocationManager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        SyncServiceManger.shared.updateInBackground()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if ((status == .authorizedAlways) || (status == .authorizedWhenInUse) || (status == .authorizedAlways)){
            startUpdateLocation()
        }
    }
    
}
