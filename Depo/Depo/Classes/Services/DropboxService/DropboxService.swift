//
//  DropboxService.swift
//  Depo
//
//  Created by Максим Деханов on 04.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

enum DropboxStatusValue: String  {
    case pending = "PENDING"
    case running = "RUNNING"
    case failed = "FAILED"
    case waitingAction = "WAITING_ACTION"
    case scheduled = "SCHEDULED"
    case finished = "FINISHED"
    case cancelled = "CANCELLED"
    case none = ""
}
struct DropboxStatusResponseKey {
    static let quotaValid = "quotaValid"
    static let connected = "connected"
    static let failedSize = "failedSize"
    static let failedCount = "failedCount"
    static let progress = "progress"
    static let successSize = "successSize"
    static let successCount = "successCount"
    static let skippedCount = "skippedCount"
    static let totalSize = "totalSize"
    static let status = "status"
    static let date = "date"
}

class DropboxStatusObject: ObjectRequestResponse {
    var isQuotaValid: Bool?
    var connected: Bool?
    var failedSize: Int?
    var failedCount: Int?
    var successSize: Int?
    var successCount: Int?
    var progress: Int?
    var skippedCount: Int?
    var totalSize: Int?
    var status: DropboxStatusValue!
    var date: Date?
    
    override func mapping() {
        isQuotaValid = json?[DropboxStatusResponseKey.quotaValid].bool
        connected = json?[DropboxStatusResponseKey.connected].bool
        failedSize = json?[DropboxStatusResponseKey.failedSize].int
        failedCount = json?[DropboxStatusResponseKey.failedCount].int
        progress = json?[DropboxStatusResponseKey.progress].int
        successSize = json?[DropboxStatusResponseKey.successSize].int
        successCount = json?[DropboxStatusResponseKey.successCount].int
        skippedCount = json?[DropboxStatusResponseKey.skippedCount].int
        totalSize = json?[DropboxStatusResponseKey.totalSize].int
        status = DropboxStatusValue(rawValue: (json?[DropboxStatusResponseKey.status].string) ?? "")
        date = json?[DropboxStatusResponseKey.date].date
    }
}

class DropboxAuth: BaseRequestParametrs {
    private let consumerKey: String
    private let currentToken: String
    private let appSecret: String
    private let authTokenSecret: String
    
    override var patch: URL {
        return RouteRequests.dropboxAuthUrl
    }
    
    override var header: RequestHeaderParametrs {
        let param = String(format: "OAuth oauth_version=\"1.0\", oauth_signature_method=\"PLAINTEXT\", oauth_consumer_key=\"%@\", oauth_token=\"%@\", oauth_signature=\"%@&%@\"", consumerKey, currentToken, appSecret, authTokenSecret)
        return [HeaderConstant.Authorization :param]
    }
    
    init(withCurrentToken currentToken: String, withConsumerKey consumerKey: String, withAppSecret appSecret: String, withAuthTokenSecret authTokenSecret: String) {
        self.consumerKey = consumerKey
        self.currentToken = currentToken
        self.appSecret = appSecret
        self.authTokenSecret = authTokenSecret
    }
}

class DropboxConnect: BaseRequestParametrs {
    private let token: String
    
    override var patch: URL {
        let patch_ = String(format: RouteRequests.dropboxConnect, token)
        return  URL(string: patch_, relativeTo:RouteRequests.BaseUrl)!
    }
    
    init(withToken token: String) {
        self.token = token
    }
}

class DropboxStatus: BaseRequestParametrs {
    
    override var patch: URL {
        return URL(string: RouteRequests.dropboxStatus, relativeTo: super.patch)!
    }
}

class DropboxStart: BaseRequestParametrs {
    
    override var patch: URL {
        return URL(string: RouteRequests.dropboxStart, relativeTo: super.patch)!
    }
}

class DropboxService: BaseRequestService {
   
    func requestToken(withCurrentToken currentToken: String, withConsumerKey consumerKey: String, withAppSecret appSecret: String, withAuthTokenSecret authTokenSecret: String, success: SuccessResponse?, fail: FailResponse?) {
        let dropbox = DropboxAuth(withCurrentToken: currentToken, withConsumerKey: consumerKey, withAppSecret: appSecret, withAuthTokenSecret: authTokenSecret)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: dropbox, handler: handler)
    }
    
    func requestConnect(withToken token: String, success: SuccessResponse?, fail: FailResponse?) {
        let dropbox = DropboxConnect(withToken: token)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: dropbox, handler: handler)
    }
    
    func requestStatus(success: SuccessResponse?, fail: FailResponse?) {
        let dropbox = DropboxStatus()
        let handler = BaseResponseHandler<DropboxStatusObject, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: dropbox, handler: handler)
    }
    
    func requestStart(success: SuccessResponse?, fail: FailResponse?) {
        let dropbox = DropboxStart()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: dropbox, handler: handler)

    }
}
