//
//  NotificationResponse.swift
//  Depo
//
//  Created by yilmaz edis on 13.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

struct NotificationJsonKey {
    static let notificationType = "notificationType"
    static let url = "url"
    static let title = "title"
    static let body = "body"
    static let image = "image"
    static let smallThumbnail = "smallThumbnail"
    static let largeThumbnail = "largeThumbnail"
    static let priority = "priority"
    static let language = "language"
    static let button1Text = "button1Text"
    static let button1Action = "button1Action"
    static let button2Text = "button2Text"
    static let button2Action = "button2Action"
    static let readCondition = "readCondition"
    static let communicationNotificationId = "communicationNotificationId"
    static let closable = "closable"
}

final class NotificationServiceResponse: ObjectRequestResponse, Map {
    
    var notificationType: String? // not null
    var url: String?
    var title: String? // not null
    var body: String?
    var image: String?
    var smallThumbnail: String?
    var largeThumbnail: String?
    var priority: Int? // not null
    var language: String? // not null
    var button1Text: String?
    var button1Action: String?
    var button2Text: String?
    var button2Action: String?
    var readCondition: String? // not null
    var communicationNotificationId: Int? // not null
    var closable: Bool? // not null
    
    override func mapping() {
        notificationType = json?[NotificationJsonKey.notificationType].string
        url = json?[NotificationJsonKey.url].string
        title = json?[NotificationJsonKey.title].string
        body = json?[NotificationJsonKey.body].string
        image = json?[NotificationJsonKey.image].string
        smallThumbnail = json?[NotificationJsonKey.smallThumbnail].string
        largeThumbnail = json?[NotificationJsonKey.largeThumbnail].string
        priority = json?[NotificationJsonKey.priority].int
        language = json?[NotificationJsonKey.language].string
        button1Text = json?[NotificationJsonKey.button1Text].string
        button1Action = json?[NotificationJsonKey.button1Action].string
        button2Text = json?[NotificationJsonKey.button2Text].string
        button2Action = json?[NotificationJsonKey.button2Action].string
        readCondition = json?[NotificationJsonKey.readCondition].string
        communicationNotificationId = json?[NotificationJsonKey.communicationNotificationId].int
        closable = json?[NotificationJsonKey.closable].bool
    }
}

final class NotificationResponse: ObjectRequestResponse, Map {
    
    var list: Array<NotificationServiceResponse> = []
    
    override func mapping() {
        let  tmpList = json?.array
        if let result = tmpList?.compactMap({ NotificationServiceResponse(withJSON: $0) }) {
            list = result
        }
    }
}
