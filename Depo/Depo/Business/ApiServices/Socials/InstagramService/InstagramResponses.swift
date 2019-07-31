//
//  InstagramResponses.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

final class SocialStatusResponse: ObjectRequestResponse {
    
    private struct SocialStatusKeys {
        static let facebook = "facebook"
        static let twitter = "twitter"
        static let instagram = "instagram"
        static let instagramUsername = "instagramUsername"
        static let spotifyStatus = "spotifyStatus"
        static let spotifyConnected = "connected"
        static let spotifyUserName = "userName"
        static let spotifyJobStatus = "jobStatus"
        static let spotifyLastModifiedDate = "lastModifiedDate"

        //static let dropbox = "dropbox"
    }
    
    var facebook: Bool?
    var twitter: Bool?
    var instagram: Bool?
    var instagramUsername: String?
    var spotifyConnected: Bool?
    var spotifyUserName: String?
    var spotifyJobStatus: String?
    var spotifyLastModifiedDate: String?
    //var dropbox: Bool?
    
    override func mapping() {
        facebook = json?[SocialStatusKeys.facebook].bool
        twitter = json?[SocialStatusKeys.twitter].bool
        instagram = json?[SocialStatusKeys.instagram].bool
        instagramUsername = json?[SocialStatusKeys.instagramUsername].string
        spotifyConnected = json?[SocialStatusKeys.spotifyStatus][SocialStatusKeys.spotifyConnected].bool
        spotifyUserName = json?[SocialStatusKeys.spotifyStatus][SocialStatusKeys.spotifyUserName].string
        spotifyJobStatus = json?[SocialStatusKeys.spotifyStatus][SocialStatusKeys.spotifyJobStatus].string
        spotifyLastModifiedDate = json?[SocialStatusKeys.spotifyStatus][SocialStatusKeys.spotifyLastModifiedDate].string
        //dropbox = json?[SocialStatusKeys.dropbox].bool
    }
}

final class InstagramConfigResponse: ObjectRequestResponse {
    
    private struct InstagramConfigKeys {
        static let clientId = "clientId"
        static let authURL = "authURL"
    }
    
    var clientID: String?
    var authURL: URL?
    
    override func mapping() {
        clientID = json?[InstagramConfigKeys.clientId].string
        authURL = json?[InstagramConfigKeys.authURL].url
    }
}

final class SocialSyncStatusResponse: ObjectRequestResponse {
    
    var status: Bool?
    
    override func mapping() {
        status = json?.bool
    }
}

final class SendSocialSyncStatusResponse: ObjectRequestResponse {
    override func mapping() {
        
    }
}

final class CreateMigrationResponse: ObjectRequestResponse {
    
    private struct CreateMigrationKeys {
        static let createDate = "createDate"
        static let lastModifiedDate = "lastModifiedDate"
        static let createdBy = "createdBy"
        static let operationType = "operationType"
        static let transactionId = "transactionId"
        static let msisdn = "msisdn"
        static let status = "status"
        static let requestBody = "requestBody"
        static let responseBody = "responseBody"
        static let id = "id"
        static let progress = "progress"
        static let funambolContactCount = "funambolContactCount"
        static let successContactCount = "successContactCount"
        static let failedContactCount  = "failedContactCount"
        static let funambolFileCount = "funambolFileCount"
        static let successFileCount  = "successFileCount"
        static let failedFileCount = "failedFileCount"
        static let isTriggeredByUser  = "isTriggeredByUser"
    }
    
    var createDate: Date?
    var lastModifiedDate: Date?
    var createdBy: String?
    var operationType: String?
    var transactionId: String?
    var msisdn: String?
    var status: String?
    var requestBody: String?
    var responseBody: String?
    var id: String?
    var progress: Int?
    var funambolContactCount: Int?
    var successContactCount: Int?
    var failedContactCount: Int?
    var funambolFileCount: Int?
    var successFileCount: Int?
    var failedFileCount: Int?
    var isTriggeredByUser: Bool?
    
    override func mapping() {
        createDate = json?[CreateMigrationKeys.createDate].date
        lastModifiedDate = json?[CreateMigrationKeys.lastModifiedDate].date
        createdBy = json?[CreateMigrationKeys.createdBy].string
        operationType = json?[CreateMigrationKeys.operationType].string
        transactionId = json?[CreateMigrationKeys.transactionId].string
        msisdn = json?[CreateMigrationKeys.msisdn].string
        status = json?[CreateMigrationKeys.status].string
        requestBody = json?[CreateMigrationKeys.requestBody].string
        responseBody = json?[CreateMigrationKeys.responseBody].string
        id = json?[CreateMigrationKeys.id].string
        progress = json?[CreateMigrationKeys.progress].int
        funambolContactCount = json?[CreateMigrationKeys.funambolContactCount].int
        successContactCount = json?[CreateMigrationKeys.successContactCount].int
        failedContactCount = json?[CreateMigrationKeys.failedContactCount].int
        funambolFileCount = json?[CreateMigrationKeys.funambolFileCount].int
        successFileCount = json?[CreateMigrationKeys.successFileCount].int
        failedFileCount = json?[CreateMigrationKeys.failedFileCount].int
        isTriggeredByUser = json?[CreateMigrationKeys.isTriggeredByUser].bool
    }
}

final class CancelMigrationResponse: ObjectRequestResponse {
    override func mapping() {
        
    }
}
