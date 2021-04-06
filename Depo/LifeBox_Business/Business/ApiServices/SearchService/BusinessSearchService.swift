//
//  BusinessSearchService.swift
//  Depo
//
//  Created by Alex Developer on 05.04.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
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

///    Sample Request Body:
///    { "diskTypes": [ "ME" ], "text": "string", "page": 0, "size": 20 }
///    This API should be called with pagination
///    "Text" field should contain what user typed in search area
///    If you call this API on MY DISK page, set diskTypes as ME as above
///    If you call this API on SHARED AREA page, set diskTypes as COMPANY
    func search(text: String, diskType: SearchDiskTypes, page: Int, size: Int, handler: @escaping ResponseVoid) {
        let url = RouteRequests.privateShareSearch
        let params: [[String: Any]] = [[
            "text": text,
            "diskTypes": [diskType.requestProperty],
            "page": page,
            "size": size
        ]]
        let urlRequest: URLRequest? = sessionManager.request(url, method: .post).request
        
        if let unwrapedRequest = urlRequest,
           let request = try? params.encode(unwrapedRequest, with: nil) {
            sessionManager
                .request(request)
                .customValidate()
                .responseVoid(handler)
        }
    }
    
}
