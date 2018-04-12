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
    
    private let locationManager = CLLocationManager()
    
    static let shared = LocationManager()
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    private override init() {
        super.init()
        configurateLocationManager()
    }
    
    private func configurateLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100 //kCLDistanceFilterNone - any changes
        locationManager.pausesLocationUpdatesAutomatically = false
        
    }
    
    func checkDoWeNeedShowLocationPermissionAllert(yesWeNeed:@escaping VoidHandler) {
        log.debug("LocationManager checkDoWeNeedShowLocationPermissionAllert")
        SingletonStorage.shared.getUniqueUserID(success: { uniqueUserID in
            let key = uniqueUserID + "locationPermission"
            let permission = UserDefaults.standard.integer(forKey: key)
            if permission == 0 {
                UserDefaults.standard.set(1, forKey: key)
                UserDefaults.standard.synchronize()
                yesWeNeed()
            }
        }) {
            
        }
    }
    
    func showIfNeedLocationPermissionAllert() {
        log.debug("LocationManager showIfNeedLocationPermissionAllert")

        self.checkDoWeNeedShowLocationPermissionAllert(yesWeNeed: {
            let controller = UIAlertController.init(title: "", message: TextConstants.locationServiceDisable, preferredStyle: .alert)
            let okAction = UIAlertAction(title: TextConstants.ok, style: .default, handler: { action in
                UIApplication.shared.openGlobalSettings()
            })
            let cancelAction = UIAlertAction(title: TextConstants.cancel, style: .cancel, handler: nil)
            controller.addAction(okAction)
            controller.addAction(cancelAction)
            RouterVC().presentViewController(controller: controller)
        })
    }
    
    func startUpdateLocation() {
        log.debug("LocationManager startUpdateLocation")
        let settings = AutoSyncDataStorage().getAutosyncSettings()
        
        if settings.isAutoSyncEnabled {
            if CLLocationManager.locationServicesEnabled() {
                if CLLocationManager.authorizationStatus() == .notDetermined {
                    self.passcodeStorage.systemCallOnScreen = true
                    self.locationManager.requestAlwaysAuthorization()
                } else {
                    self.locationManager.startMonitoringSignificantLocationChanges()
                    self.locationManager.allowsBackgroundLocationUpdates = true
                    self.locationManager.startUpdatingLocation()
                }
            } else {
                self.showIfNeedLocationPermissionAllert()
            }
        }
    }
 
    func stopUpdateLocation() {
        log.debug("LocationManager stopUpdateLocation")

        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    // CLLocationManager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        log.debug("LocationManager locationManager")

        SyncServiceManager.shared.updateInBackground()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        log.debug("LocationManager locationManager")

        passcodeStorage.systemCallOnScreen = false
        
        var isAuthorized = false
        if ((status == .authorizedAlways) || (status == .authorizedWhenInUse) || (status == .authorizedAlways)) {
            isAuthorized = true
            startUpdateLocation()
        }
        MenloworksTagsService.shared.onLocationPermissionChanged(isAuthorized)
    }
    
}
