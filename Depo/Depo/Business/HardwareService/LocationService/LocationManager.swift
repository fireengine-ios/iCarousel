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
    
    typealias RequestAuthorizationStatusHandler = (_ status: CLAuthorizationStatus) -> Void
    
    private let locationManager = CLLocationManager()
    
    static let shared = LocationManager()
    
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    
    private var requestAuthorizationStatusHandler: RequestAuthorizationStatusHandler?
    
    
    
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
    
    func authorizationStatus(_ completion: @escaping (_ status: CLAuthorizationStatus) -> Void) {
        if !CLLocationManager.locationServicesEnabled() {
            completion(.restricted)
            return
        }
        
        let currentStatus = CLLocationManager.authorizationStatus()
        if currentStatus == .notDetermined {
            requestAuthorizationStatusHandler = completion
            locationManager.requestAlwaysAuthorization()
        } else {
            completion(currentStatus)
        }
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
    
    func startUpdateLocationInBackground() {
        log.debug("LocationManager startUpdateLocationInBackground")
        let settings = AutoSyncDataStorage().settings
        
        guard settings.isAutoSyncEnabled,
            CLLocationManager.locationServicesEnabled(),
            CLLocationManager.authorizationStatus() == .authorizedAlways
        else {
            return
        }
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        
    }
    
    func startUpdateLocation() {
        log.debug("LocationManager startUpdateLocation")
        let settings = AutoSyncDataStorage().settings
        
        if settings.isAutoSyncEnabled {
            if CLLocationManager.locationServicesEnabled() {
                if CLLocationManager.authorizationStatus() == .notDetermined {
                    passcodeStorage.systemCallOnScreen = true
                    locationManager.requestAlwaysAuthorization()
                } else {
                    locationManager.allowsBackgroundLocationUpdates = true
                    locationManager.startMonitoringSignificantLocationChanges()
                }
            } else {
                showIfNeedLocationPermissionAllert()
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
        
        guard tokenStorage.accessToken != nil else {
            return
        }
        
        SyncServiceManager.shared.updateInBackground()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.debug("LocationManager didFailWithError: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        log.debug("LocationManager locationManager")

        passcodeStorage.systemCallOnScreen = false
        
        var isAuthorized = false
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            isAuthorized = true
            startUpdateLocation()
        }
        MenloworksTagsService.shared.onLocationPermissionChanged(isAuthorized)
        
        if status != .notDetermined, let handler = requestAuthorizationStatusHandler {
            handler(status)
        }
    }
    
}
