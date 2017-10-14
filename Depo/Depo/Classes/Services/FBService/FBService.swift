//
//  FBService.swift
//  Depo
//
//  Created by Maksim Rahleev on 07/08/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON
import FBSDKLoginKit

public enum FBStatusValue: String  {
    case pending = "PENDING"
    case running = "RUNNING"
    case failed = "FAILED"
    case waitingAction = "WAITING_ACTION"
    case scheduled = "SCHEDULED"
    case finished = "FINISHED"
    case cancelled = "CANCELLED"
    case none = ""
}

struct FBStatusResponseKey {
    static let connected = "connected"
    static let syncEnabled = "syncEnabled"
    static let lastDate = "date"
    static let status = "status"
}

struct FBPermissionsResponseKey {
    static let read = "read"
    static let write = "write"
}

class FBStatusObject: ObjectRequestResponse {
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

class FBPermissions: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: RouteRequests.fbPermissions, relativeTo: super.patch)!
    }
}

class FBConnect: BaseRequestParametrs {
    
    private let token: String
    
    override var patch: URL {
        let patch = String(format: RouteRequests.fbConnect, token)
        return URL(string: patch, relativeTo: super.patch)!
    }
    
    init(withToken token: String) {
        self.token = token
    }
}

class FBStatus: BaseRequestParametrs {
     override var patch: URL {
        return URL(string: RouteRequests.fbStatus, relativeTo: super.patch)!
    }
}

class FBStart: BaseRequestParametrs {
    override var patch: URL {
        return URL(string: RouteRequests.fbStart, relativeTo: super.patch)!
    }
}

class FBStop: BaseRequestParametrs {
    
    override var patch: URL {
        return URL(string: RouteRequests.fbStop, relativeTo: super.patch)!
    }
}

class FBService: BaseRequestService {
    func requestToken(permissions: [String], success: ((String) -> ())?, fail: FailResponse?) {
        let vc = (UIApplication.shared.delegate as! AppDelegate).window.rootViewController!
        
        FBSDKLoginManager().logIn(withReadPermissions: permissions, from: vc) { (result, error) in
            if let error = error {
                fail?(.error(error))
            } else if let result = result {
                if result.isCancelled {
                    fail?(.string("FB Login canceled"))
                } else {
                    success?(result.token.tokenString)
                }
            }
        }
    }
    
    func requestPermissions(success: SuccessResponse?, fail: FailResponse?) {
        let fb = FBPermissions()
        let handler = BaseResponseHandler<FBPermissionsObject, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
    
    func requestConnect(withToken token: String, success: SuccessResponse?, fail: FailResponse?) {
        let fb = FBConnect(withToken: token)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: fb, handler: handler)
    }
    
    func requestStatus(success: SuccessResponse?, fail: FailResponse?) {
        let fb = FBStatus()
        let handler = BaseResponseHandler<FBStatusObject, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
    
    func requestStart(success: SuccessResponse?, fail: FailResponse?) {
        let fb = FBStart()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
    
    func requestStop(success: SuccessResponse?, fail: FailResponse?) {
        let fb = FBStop()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: fb, handler: handler)
    }
    
}
