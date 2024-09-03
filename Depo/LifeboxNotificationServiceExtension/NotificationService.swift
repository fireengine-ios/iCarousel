//
//  NotificationService.swift
//  LifeboxNotificationServiceExtension
//
//  Created by Ozan Salman on 30.11.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UserNotifications
import NetmeraNotificationServiceExtension

class NotificationService : NetmeraNotificationServiceExtension {

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (_ contentToDeliver: UNNotificationContent) -> Void) {
        super.didReceive(request, withContentHandler: contentHandler)
    }

    override func serviceExtensionTimeWillExpire() {
        super.serviceExtensionTimeWillExpire()
    }
}
