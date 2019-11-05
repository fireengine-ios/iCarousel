//
//  NotificationService.swift
//  NotificationService
//
//  Created by Raman Harhun on 3/3/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UserNotifications

class NotificationService: NetmeraNotificationServiceExtension {

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (_ contentToDeliver: UNNotificationContent) -> Void) {
        super.didReceive(request, withContentHandler: contentHandler)
    }
    
    override func serviceExtensionTimeWillExpire() {
        super.serviceExtensionTimeWillExpire()
    }
    
//    var contentHandler: ((UNNotificationContent) -> Void)?
//    var bestAttemptContent: UNMutableNotificationContent?
//
//    let session = URLSession(configuration: URLSessionConfiguration.default)
//
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        self.contentHandler = contentHandler
//        self.bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent
//
//        guard let bestAttemptContent = bestAttemptContent else {
//            return
//        }
//
//        guard let pictureURLString = bestAttemptContent.userInfo["picture"] as? String,
//              let pictureURL = URL(string: pictureURLString) else {
//            contentHandler(bestAttemptContent)
//            return
//        }
//
//        session.downloadTask(with: pictureURL, completionHandler: { tmpPictureLocationURL, response, error in
//            guard error != nil, let tmpPictureLocationURL = tmpPictureLocationURL, let fileName = response?.url?.lastPathComponent else {
//                contentHandler(bestAttemptContent)
//                return
//            }
//
//            let attachmentURL = URL(fileURLWithPath: tmpPictureLocationURL.path + fileName)
//
//            do {
//                try FileManager.default.moveItem(at: tmpPictureLocationURL, to: attachmentURL)
//                let attachment = try UNNotificationAttachment(identifier: "", url: attachmentURL, options: nil)
//
//                bestAttemptContent.attachments = [attachment]
//                contentHandler(bestAttemptContent)
//            } catch {
//                contentHandler(bestAttemptContent)
//            }
//
//        }).resume()
//    }
//
//    override func serviceExtensionTimeWillExpire() {
//        // Called just before the extension will be terminated by the system.
//        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
//        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
//            contentHandler(bestAttemptContent)
//        }
//    }
}
