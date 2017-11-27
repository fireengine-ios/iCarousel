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
    
    func startUpdateLocation(){
        if CLLocationManager.locationServicesEnabled(){
            if CLLocationManager.authorizationStatus() == .notDetermined{
                locationManager.requestAlwaysAuthorization()
            }else {
                locationManager.startMonitoringSignificantLocationChanges()
                if #available(iOS 9.0, *) {
                    locationManager.allowsBackgroundLocationUpdates = true
                }
                locationManager.startUpdatingLocation()
            }
        }
    }
 
    func stopUpdateLocation(){
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    // CLLocationManager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        SyncService.default.startAutoSyncInBG()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if ((status == .authorizedAlways) || (status == .authorizedWhenInUse) || (status == .authorizedAlways)){
            startUpdateLocation()
        }
    }
    
}
