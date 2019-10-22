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
            static let content = "content"
            static let messageType = "messageType"
            static let title = "title"
            static let message = "message"
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
    
    let detailsUrl: URL
    let imageUrl: URL
    let messageType: MessageType
    let title: String
    let message: String
    
    let totalUsed: Int
    let maxDailyLimit: Int
    let dailyUsed: Int
    let dailyRemaining: Int
    
    let startDate: Date
    let endDate: Date
    let launchDate: Date

    init(detailsUrl: URL,
         imageUrl: URL,
         messageType: MessageType,
         title: String,
         message: String,
         totalUsed: Int,
         dailyUsed: Int,
         maxDailyLimit: Int,
         dailyRemaining: Int,
         startDate: Date,
         endDate: Date,
         launchDate: Date) {
        
        self.detailsUrl = detailsUrl
        self.imageUrl = imageUrl
        self.messageType = messageType
        self.title = title
        self.message = message
        
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
            let detailsUrl = json[ResponseKey.detailsUrl].url,
            let imageUrl = json[ResponseKey.imageUrl].url,
            let messageType = MessageType(rawValue: content[ResponseKey.messageType].stringValue),
            let title = content[ResponseKey.title].string,
            let message = content[ResponseKey.message].string,
            
            let totalUsed = usage[ResponseKey.totalUsed].int,
            let maxDailyLimit = usage[ResponseKey.maxDailyLimit].int,
            let dailyUsed = usage[ResponseKey.dailyUsed].int,
            let dailyRemaining = usage[ResponseKey.dailyRemaining].int,
           
            let startDate = dates[ResponseKey.startDate].date,
            let endDate = dates[ResponseKey.endDate].date,
            let launchDate = dates[ResponseKey.launchDate].date
        else {
            assertionFailure()
            return nil
        }

        self.init(detailsUrl: detailsUrl, imageUrl: imageUrl, messageType: messageType, title: title, message: message, totalUsed: totalUsed, dailyUsed: dailyUsed, maxDailyLimit: maxDailyLimit, dailyRemaining: dailyRemaining, startDate: startDate, endDate: endDate, launchDate: launchDate)
    }
}

enum CampaignPhotopickError {
    case empty
    case error(Error)
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
