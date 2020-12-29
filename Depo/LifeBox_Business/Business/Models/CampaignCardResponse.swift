//
//  CampaignCardResponse.swift
//  Depo
//
//  Created by Maxim Soldatov on 10/18/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

enum MessageType: String {
    case backend = "BACKEND"
    case client = "CLIENT"
}

final class CampaignCardResponse {
    
        private enum ResponseKey {
            static let detailsUrl = "detailsUrl"
            static let imageUrl = "imageUrl"
            static let videoUrl = "videoUrl"
            static let content = "content"
            static let messageType = "messageType"
            static let title = "title"
            static let message = "message"
            static let detailsText = "detailsText"
            static let usage = "usage"
            static let totalUsed = "totalUsed"
            static let maxDailyLimit = "maxDailyLimit"
            static let dailyUsed = "dailyUsed"
            static let dailyRemaining = "dailyRemaining"
            static let dates = "dates"
            static let startDate = "startDate"
            static let endDate = "endDate"
            static let launchDate = "launchDate"
        }
    
    let detailsUrl: String
    let imageUrl: URL
    let videoUrl: URL?
    let messageType: MessageType
    let title: String
    let message: String
    let detailsText: String
    
    let totalUsed: Int
    let maxDailyLimit: Int
    let dailyUsed: Int
    let dailyRemaining: Int
    
    let startDate: Date
    let endDate: Date
    let launchDate: Date

    init(detailsUrl: String,
         imageUrl: URL,
         videoUrl: URL?,
         messageType: MessageType,
         title: String,
         message: String,
         detailsText: String,
         totalUsed: Int,
         dailyUsed: Int,
         maxDailyLimit: Int,
         dailyRemaining: Int,
         startDate: Date,
         endDate: Date,
         launchDate: Date) {
        
        self.detailsUrl = detailsUrl
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
        self.messageType = messageType
        self.title = title
        self.message = message
        self.detailsText = detailsText
        
        self.totalUsed = totalUsed
        self.maxDailyLimit = maxDailyLimit
        self.dailyUsed = dailyUsed
        self.dailyRemaining = dailyRemaining
        
        self.startDate = startDate
        self.endDate = endDate
        self.launchDate = launchDate
    }
    
    convenience init?(json: JSON) {
         
        let content = json[ResponseKey.content]
        let usage = json[ResponseKey.usage]
        let dates = json[ResponseKey.dates]
        
        guard
            let detailsUrl = json[ResponseKey.detailsUrl].string,
            let imageUrl = json[ResponseKey.imageUrl].url,
            let messageType = MessageType(rawValue: content[ResponseKey.messageType].stringValue),
           
            let startDate = dates[ResponseKey.startDate].date,
            let endDate = dates[ResponseKey.endDate].date,
            let launchDate = dates[ResponseKey.launchDate].date
        else {
            return nil
        }
        
        let totalUsed = usage[ResponseKey.totalUsed].int
        let maxDailyLimit = usage[ResponseKey.maxDailyLimit].int
        let dailyUsed = usage[ResponseKey.dailyUsed].int
        let dailyRemaining = usage[ResponseKey.dailyRemaining].int
    
        //for messageType == .client usage fields are required
        if messageType == .client && (totalUsed == nil || maxDailyLimit == nil || dailyUsed == nil || dailyRemaining == nil) {
            return nil
        }
        
        let title = content[ResponseKey.title].string ?? ""
        let message = content[ResponseKey.message].string ?? ""
        let detailsText = content[ResponseKey.detailsText].string ?? ""
        let videoUrl = json[ResponseKey.videoUrl].url
        
        self.init(detailsUrl: detailsUrl,
                  imageUrl: imageUrl,
                  videoUrl: videoUrl,
                  messageType: messageType,
                  title: title,
                  message: message,
                  detailsText: detailsText,
                  totalUsed: totalUsed ?? 0,
                  dailyUsed: dailyUsed ?? 0,
                  maxDailyLimit: maxDailyLimit ?? 0,
                  dailyRemaining: dailyRemaining ?? 0,
                  startDate: startDate,
                  endDate: endDate,
                  launchDate: launchDate)
    }
}

enum CampaignPhotopickError {
    case empty
    case error(Error)
}

extension CampaignPhotopickError {
    func isEmpty() -> Bool {
        switch self {
        case .empty:
            return true
        default:
            return false
        }
    }
}

extension CampaignPhotopickError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .empty:
            return "\(RouteRequests.campaignPhotopick) not Campaign Photopick Status in response"
        case .error(let error):
            return error.description
        }
    }
}
