//
//  FBResponses.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/6/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

class FBStatusObject: ObjectRequestResponse {
    
    private struct FBStatusResponseKey {
        static let connected = "connected"
        static let syncEnabled = "syncEnabled"
        static let lastDate = "date"
        static let status = "status"
    }
    
    var connected: Bool?
    var syncEnabled: Bool?
    var lastDate: Date?
    var status: FBStatusValue?
    
    override func mapping() {
        connected = json?[FBStatusResponseKey.connected].bool
        syncEnabled = json?[FBStatusResponseKey.syncEnabled].bool
        lastDate = json?[FBStatusResponseKey.lastDate].date
        status = FBStatusValue(rawValue: json?[FBStatusResponseKey.connected].string ?? "")
    }
}

class FBPermissionsObject: ObjectRequestResponse {
    
    private struct FBPermissionsResponseKey {
        static let read = "read"
        static let write = "write"
    }
    
    var read: [String]?
    var write: [String]?
    
    override func mapping() {
        if let dict = json?.dictionary {
            read = dict[FBPermissionsResponseKey.read]?.arrayObject as? [String]
            write = dict[FBPermissionsResponseKey.write]?.arrayObject as? [String]
        } else if let array = json?.arrayObject {
            read = array as? [String]
        }
    }
}
