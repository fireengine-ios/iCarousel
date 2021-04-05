//
//  BusinessSearchService.swift
//  Depo
//
//  Created by Alex Developer on 05.04.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Alamofire
import SwiftyJSON

enum SearchDiskTypes {
    case myDisk
    case sharedArea
    
    var requestProperty: String {
        switch self {
        case .myDisk:
            return "ME"
        case .sharedArea:
            return "COMPANY"
        }
    }
}

class BusinessSearchService: BaseRequestService {
    
    private lazy var sessionManager: SessionManager = factory.resolve()

//    Sample Request Body:
//    { "diskTypes": [ "ME" ], "text": "string", "page": 0, "size": 20 }
//    This API should be called with pagination
//    "Text" field should contain what user typed in search area
//    If you call this API on MY DISK page, set diskTypes as ME as above
//    If you call this API on SHARED AREA page, set diskTypes as COMPANY
    
    
    func storageUsageInfo(projectId: String,
                          accoundId: String,
                          handler: @escaping (ResponseResult<SettingsStorageUsageResponseItem>) -> Void) {
        

        
//        let url = RouteRequests.Account.Permissions.permissionsUpdate
//        let params: [[String: Any]] = [["type": type.rawValue,
//                                        "approved": isApproved]]
//
//        let urlRequest = sessionManager.request(url, method: .post).request
//
//        if var request = urlRequest {
//            request = try! params.encode(request, with: nil)
//
//            sessionManager
//                .request(request)
//                .customValidate()
//                .responseVoid(handler)
//        }
        
        
        guard let url = URL(string: String(format: RouteRequests.BusinessAccount.storageUsageInfo, projectId, accoundId)) else {
            handler(.failed(ErrorResponse.string("Incorrect URL")))
            return
        }

        sessionManager
            .request(url)
            .customValidate()
            .responseObject(handler)
    }
    
}
