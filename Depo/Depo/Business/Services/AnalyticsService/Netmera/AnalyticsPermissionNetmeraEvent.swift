//
//  AnalyticsPermissionNetmeraEvent.swift
//  Depo
//
//  Created by ÜNAL ÖZTÜRK on 27.01.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import UserNotifications

final class AnalyticsPermissionNetmeraEvent {
    
    static func sendContactPermissionNetmeraEvents(_ isAuthorized: Bool) {
        if isAuthorized {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AppPermission(value: NetmeraEventValues.AppPermissionValue.always.text, type: NetmeraEventValues.AppPermissionType.contact.text, status: NetmeraEventValues.AppPermissionStatus.granted.text))
        } else {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AppPermission(value: NetmeraEventValues.AppPermissionValue.never.text, type: NetmeraEventValues.AppPermissionType.contact.text, status: NetmeraEventValues.AppPermissionStatus.notGranted.text))
        }
    }
    
    static func sendPhotoPermissionNetmeraEvents(_ isAuthorized: Bool) {
        if isAuthorized {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AppPermission(value: NetmeraEventValues.AppPermissionValue.always.text, type: NetmeraEventValues.AppPermissionType.gallery.text, status: NetmeraEventValues.AppPermissionStatus.granted.text))
        } else {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AppPermission(value: NetmeraEventValues.AppPermissionValue.never.text, type: NetmeraEventValues.AppPermissionType.gallery.text, status: NetmeraEventValues.AppPermissionStatus.notGranted.text))
        }
    }
    
    static func sendLocationPermissionNetmeraEvents(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AppPermission(value: NetmeraEventValues.AppPermissionValue.inUse.text, type: NetmeraEventValues.AppPermissionType.location.text, status: NetmeraEventValues.AppPermissionStatus.granted.text))
         case .authorizedWhenInUse:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AppPermission(value: NetmeraEventValues.AppPermissionValue.allowOnce.text, type: NetmeraEventValues.AppPermissionType.location.text, status: NetmeraEventValues.AppPermissionStatus.granted.text))
        case .denied, .notDetermined, .restricted:
             AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AppPermission(value: NetmeraEventValues.AppPermissionValue.never.text, type: NetmeraEventValues.AppPermissionType.location.text, status: NetmeraEventValues.AppPermissionStatus.notGranted.text))
        }
    }
    
    static func sendNotificationPermissionNetmeraEvents() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            
            if settings.authorizationStatus == .authorized {
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AppPermission(value: NetmeraEventValues.AppPermissionValue.always.text, type: NetmeraEventValues.AppPermissionType.notification.text, status: NetmeraEventValues.AppPermissionStatus.granted.text))
            } else {
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AppPermission(value: NetmeraEventValues.AppPermissionValue.never.text, type: NetmeraEventValues.AppPermissionType.notification.text, status: NetmeraEventValues.AppPermissionStatus.notGranted.text))
            }
        }
    }
    
}



