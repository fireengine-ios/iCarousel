//
//  CampaignResponse.swift
//  Depo
//
//  Created by Andrei Novikau on 10/18/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

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

final class CampaignPhotopickStatus {
        
    let detailsUrl: URL
    let imageUrl: URL
    let content: CampaignContent
    let usage: CampaignUsage
    let dates: CampaignDates

    init(detailsUrl: URL, imageUrl: URL, content: CampaignContent, usage: CampaignUsage, dates: CampaignDates) {
        self.detailsUrl = detailsUrl
        self.imageUrl = imageUrl
        self.content = content
        self.usage = usage
        self.dates = dates
    }
}
    
extension CampaignPhotopickStatus {
    convenience init?(json: JSON) {
        guard
            let detailsUrl = json["detailsUrl"].url,
            let imageUrl = json["imageUrl"].url,
            let content = CampaignContent(json: json["content"]),
            let usage = CampaignUsage(json: json["usage"]),
            let dates = CampaignDates(json: json["dates"])
            else {
                assertionFailure()
                return nil
        }
    
        self.init(detailsUrl: detailsUrl, imageUrl: imageUrl, content: content, usage: usage, dates: dates)
    }
}

final class CampaignContent {
    let messageType: String
    let title: String
    let message: String
    
    init(messageType: String, title: String, message: String) {
        self.messageType = messageType
        self.title = title
        self.message = message
    }
}

extension CampaignContent {
    convenience init?(json: JSON) {
        guard
            let messageType = json["messageType"].string,
            let title = json["title"].string,
            let message = json["message"].string
            else {
                assertionFailure()
                return nil
        }
    
        self.init(messageType: messageType, title: title, message: message)
    }
}

final class CampaignUsage {
    let totalUsed: Int
    let maxDailyLimit: Int
    let dailyUsed: Int
    let dailyRemaining: Int
    
    init(totalUsed: Int, maxDailyLimit: Int, dailyUsed: Int, dailyRemaining: Int) {
        self.totalUsed = totalUsed
        self.maxDailyLimit = maxDailyLimit
        self.dailyUsed = dailyUsed
        self.dailyRemaining = dailyRemaining
    }
}

extension CampaignUsage {
    convenience init?(json: JSON) {
        guard
            let totalUsed = json["totalUsed"].int,
            let maxDailyLimit = json["maxDailyLimit"].int,
            let dailyUsed = json["dailyUsed"].int,
            let dailyRemaining = json["dailyRemaining"].int
            else {
                assertionFailure()
                return nil
        }
    
        self.init(totalUsed: totalUsed, maxDailyLimit: maxDailyLimit, dailyUsed: dailyUsed, dailyRemaining: dailyRemaining)
    }
}

final class CampaignDates {
    let startDate: Date
    let endDate: Date
    let launchDate: Date
    
    init(startDate: Date, endDate: Date, launchDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
        self.launchDate = launchDate
    }
    
    func isAvailable() -> Bool {
        let now = Date()
        return startDate <= now && now <= endDate
    }
}

extension CampaignDates {
    convenience init?(json: JSON) {
        guard
            let startDate = json["startDate"].date,
            let endDate = json["endDate"].date,
            let launchDate = json["launchDate"].date
            else {
                assertionFailure()
                return nil
        }
    
        self.init(startDate: startDate, endDate: endDate, launchDate: launchDate)
    }
}
