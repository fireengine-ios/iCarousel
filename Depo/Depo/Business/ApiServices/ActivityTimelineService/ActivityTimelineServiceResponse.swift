//
//  ActivityTimelineServiceResponse.swift
//  Depo
//
//  Created by user on 9/14/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class ActivityTimelineServiceResponse: ObjectRequestResponse {
    
    private struct ActivityTimelineJsonKey {
        static let id = "id"
        static let createdDate = "createdDate"
        static let activityType = "activityType"
        static let activityFileType = "fileType"
        static let fileUUID = "fileUUID"
        static let parentFolderUUID = "parentFolderUUID"
        static let targetFolderUUID = "targetFolderUUID"
        static let targetFileUUID = "targetFileUUID"
        static let name = "name"
        static let fileHash = "fileHash"
        static let fileSize = "fileSize"
        static let isFolder = "isFolder"
        static let deviceUUID = "deviceUUID"
        
        static let fileInfo = "fileInfo"
        static let contentType = "content_type"
        
    }
    
    var id: Int?
    var createdDate: Date?
    var activityType: ActivityType?
    var activityFileType: ActivityFileType?
    var fileUUID: String?
    var parentFolderUUID: String?
    var targetFolderUUID: String?
    var targetFileUUID: String?
    var name: String?
    var fileHash: String?
    var fileSize: Int?
    var isFolder: Bool?
    var deviceUUID: String?
    
    override func mapping() {
        id = json?[ActivityTimelineJsonKey.id].int
        createdDate = json?[ActivityTimelineJsonKey.createdDate].date?.withoutSeconds
        if let type = json?[ActivityTimelineJsonKey.activityType].string {
            activityType = ActivityType(rawValue: type)
        }

        if let fileType = json?[ActivityTimelineJsonKey.fileInfo][ActivityTimelineJsonKey.contentType].string {
            activityFileType = ActivityFileType(rawValue: fileType)
        }
        
        if activityFileType == nil, let fileType = json?[ActivityTimelineJsonKey.activityFileType].string {
            activityFileType = ActivityFileType(rawValue: fileType)
        }
        
        fileUUID = json?[ActivityTimelineJsonKey.fileUUID].string
        parentFolderUUID = json?[ActivityTimelineJsonKey.parentFolderUUID].string
        targetFolderUUID = json?[ActivityTimelineJsonKey.targetFolderUUID].string
        targetFileUUID = json?[ActivityTimelineJsonKey.targetFileUUID].string
        name = json?[ActivityTimelineJsonKey.name].string
        fileHash = json?[ActivityTimelineJsonKey.fileHash].string
        fileSize = json?[ActivityTimelineJsonKey.fileSize].int
        isFolder = json?[ActivityTimelineJsonKey.isFolder].bool
        deviceUUID = json?[ActivityTimelineJsonKey.deviceUUID].string
        
        if name == nil {
            name = json?[ActivityTimelineJsonKey.fileInfo][ActivityTimelineJsonKey.name].string
        }
        
    }
}

class ActivityTimelineResponse: ObjectRequestResponse {
    
    var list: [ActivityTimelineServiceResponse] = []
    
    override func mapping() {
        guard let tmpList = json?.array?.compactMap({ ActivityTimelineServiceResponse(withJSON: $0) }) else { return }
        list = tmpList
    }
}
