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
    static let status = "status"
    static let title = "title"
    static let body = "body"
    static let image = "image"
    static let smallThumbnail = "smallThumbnail"
    static let largeThumbnail = "largeThumbnail"
    static let priority = "priority"
    static let language = "language"
    static let button1Text = "button1Text"
    static let button1Action = "button1Action"
    static let button1Url = "button1Url"
    static let button2Text = "button2Text"
    static let button2Action = "button2Action"
    static let button2Url = "button2Url"
    static let readCondition = "readCondition"
    static let communicationNotificationId = "communicationNotificationId"
    static let closable = "closable"
    static let createdDate = "createdDate"
}

final class NotificationServiceResponse: ObjectRequestResponse, Map {
    
    var notificationType: String?
    var url: String?
    var status: String?
    var title: String?
    var body: String?
    var image: String?
    var smallThumbnail: String?
    var largeThumbnail: String?
    var priority: Int?
    var language: String?
    var button1Text: String?
    var button1Action: String?
    var button1Url: String?
    var button2Text: String?
    var button2Action: String?
    var button2Url: String?
    var readCondition: String?
    var communicationNotificationId: Int?
    var closable: Bool?
    var createdDate: UInt64?
    
    override func mapping() {
        notificationType = json?[NotificationJsonKey.notificationType].string
        url = json?[NotificationJsonKey.url].string
        status = json?[NotificationJsonKey.status].string
        title = json?[NotificationJsonKey.title].string
        body = json?[NotificationJsonKey.body].string
        image = json?[NotificationJsonKey.image].string
        smallThumbnail = json?[NotificationJsonKey.smallThumbnail].string
        largeThumbnail = json?[NotificationJsonKey.largeThumbnail].string
        priority = json?[NotificationJsonKey.priority].int
        language = json?[NotificationJsonKey.language].string
        button1Text = json?[NotificationJsonKey.button1Text].string
        button1Action = json?[NotificationJsonKey.button1Action].string
        button1Url = json?[NotificationJsonKey.button1Url].string
        button2Text = json?[NotificationJsonKey.button2Text].string
        button2Action = json?[NotificationJsonKey.button2Action].string
        button2Url = json?[NotificationJsonKey.button2Url].string
        readCondition = json?[NotificationJsonKey.readCondition].string
        communicationNotificationId = json?[NotificationJsonKey.communicationNotificationId].int
        closable = json?[NotificationJsonKey.closable].bool
        createdDate = json?[NotificationJsonKey.createdDate].uInt64
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
