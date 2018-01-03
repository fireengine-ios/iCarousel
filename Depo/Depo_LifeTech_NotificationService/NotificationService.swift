//
//  NotificationService.swift
//  Depo_LifeTech_NotificationService
//
//  Created by Konstantin on 12/1/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            return
        }
        
        self.bestAttemptContent = bestAttemptContent
        
        guard let picturePath = request.content.userInfo["picture"] as? String else {
            contentHandler(bestAttemptContent)
            return
        }
        
        if let pictureUrl = URL(string: picturePath) {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            session.downloadTask(with: pictureUrl, completionHandler: { [weak self] (tempFileLocation, response, error) in
                guard error == nil else {
                    self?.contentHandler?(bestAttemptContent)
                    return
                }
                
                let fileManager = FileManager.default
                if let attachmentPath = tempFileLocation?.path.appending(response?.url?.absoluteURL.lastPathComponent ?? "") {
                    let attachmentURL = URL(fileURLWithPath: attachmentPath)
                    do {
                        try fileManager.moveItem(at: tempFileLocation!, to: attachmentURL)
                    } catch {
                        print("Can't move item")
                    }
                    
                    do {
                        let attachment = try UNNotificationAttachment(identifier: "", url: attachmentURL, options: nil)
                        self?.bestAttemptContent?.attachments = [attachment]
                        self?.contentHandler?((self?.bestAttemptContent)!)
                    } catch {
                        print("Cant create attachment")
                    }
                }
            }).resume()
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
