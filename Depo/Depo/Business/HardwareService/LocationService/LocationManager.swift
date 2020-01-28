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
        debugLog("LocationManager checkDoWeNeedShowLocationPermissionAllert")
        SingletonStorage.shared.getUniqueUserID(success: { uniqueUserID in
            let key = uniqueUserID + "locationPermission"
            let permission = UserDefaults.standard.integer(forKey: key)
            if permission == 0 {
                UserDefaults.standard.set(1, forKey: key)
                UserDefaults.standard.synchronize()
                yesWeNeed()
            }
        }, fail: { _ in })
    }
    
    func showIfNeedLocationPermissionAllert() {
        debugLog("LocationManager showIfNeedLocationPermissionAllert")

        self.checkDoWeNeedShowLocationPermissionAllert(yesWeNeed: {
            let controller = UIAlertController.init(title: "", message: TextConstants.locationServiceDisable, preferredStyle: .alert)
            let okAction = UIAlertAction(title: TextConstants.ok, style: .default, handler: { action in
//                UIApplication.shared.openSettings()
            })
//            let cancelAction = UIAlertAction(title: TextConstants.cancel, style: .cancel, handler: nil)
            controller.addAction(okAction)
//            controller.addAction(cancelAction)
            RouterVC().presentViewController(controller: controller)
        })
    }
    
    func startUpdateLocationInBackground() {
        debugLog("LocationManager startUpdateLocationInBackground")
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
        debugLog("LocationManager startUpdateLocation")
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
//             else {
//                showIfNeedLocationPermissionAllert()

            }
        }
    }
 
    func stopUpdateLocation() {
        debugLog("LocationManager stopUpdateLocation")

        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    // CLLocationManager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugLog("LocationManager locationManager")
        
        guard tokenStorage.accessToken != nil else {
            return
        }
        
        if UIApplication.shared.applicationState == .background {
            if BackgroundTaskService.shared.appWasSuspended {
                CacheManager.shared.actualizeCache()
            }
            SyncServiceManager.shared.updateInBackground()
        }
    }   
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugLog("LocationManager didFailWithError: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        debugLog("LocationManager locationManager")

        passcodeStorage.systemCallOnScreen = false
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            startUpdateLocation()
        }
        
        if status == .authorizedAlways {
            MenloworksTagsService.shared.onLocationPermissionChanged("always")
        } else if status == .authorizedWhenInUse {
            MenloworksTagsService.shared.onLocationPermissionChanged("in use")
        } else if status == .denied {
            MenloworksTagsService.shared.onLocationPermissionChanged("denied")
        }
        
        AnalyticsPermissionNetmeraEvent.sendLocationPermissionNetmeraEvents(status)
        
        if status != .notDetermined, let handler = requestAuthorizationStatusHandler {
            handler(status)
        }
    }
    
}
