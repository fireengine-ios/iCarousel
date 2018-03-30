//
//  DropboxResponse.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 11/8/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    
    var uploadDescription: String {
        guard let date = date, let successCount = successCount else {
            return " "
        }
        let dateString = date.getDateInFormat(format: "dd.MM.yyyy")
        
        if successCount == 1 {
            return String(format: TextConstants.dropboxLastUpdatedFile, dateString, successCount)
        } else {
            return String(format: TextConstants.dropboxLastUpdatedFiles, dateString, successCount)
        }
    }
}
