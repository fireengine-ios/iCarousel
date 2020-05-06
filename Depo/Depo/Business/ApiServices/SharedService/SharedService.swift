//
//  SharedService.swift
//  Depo
//
//  Created by Alexander Gurin on 8/4/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import SwiftyJSON

enum SharedType: CustomStringConvertible {
    typealias RawValue = String
    
    case link
    case email
    case facebook
    case twitter
    
    var description: String {
        switch self {
            case .link     : return "public/v2"
            case .email    : return "email"
            case .facebook : return "social/facebook"
            case .twitter  : return "social/twitter"
        }
    }
}

struct SharedServiceConstants {
    static let fileUuidList = "fileUuidList"
    static let isAlbum = "isAlbum"
}

struct SharedServiceParam: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }
    
    let filesList: [String]
    
    let isAlbum: Bool
    
    let sharedType: SharedType
    
    var requestParametrs: Any {
        let ablbum = isAlbum ? "true":"false"
        let dict: [String: Any] =
            [SharedServiceConstants.fileUuidList   : filesList,
            SharedServiceConstants.isAlbum : ablbum]
        return dict
    }
    
    var patch: URL {
        let sharedPath = String(format: RouteRequests.share, sharedType.description )
        return URL(string: sharedPath, relativeTo: RouteRequests.baseUrl)!
    }
    
    var header: RequestHeaderParametrs {
        return RequestHeaders.authification()
    }
}


class SharedServiceResponse: ObjectRequestResponse {
    
    var url: String?
    
    required init(json: Data?, headerResponse: HTTPURLResponse?) {
        if let data = json {
            url = String(data: data, encoding: .utf8)
        }
        super.init(json: nil, headerResponse: nil)
    }
    
    required init(withJSON: JSON?) {
        fatalError("init(withJSON:) has not been implemented")
    }
}


typealias  SuccessShared = (_ url: String) -> Void

class SharedService: BaseRequestService {
    
    func share(param: SharedServiceParam, success: SuccessShared?, fail: FailResponse?) {
        debugLog("SharedService share")
        
        let handler = BaseResponseHandler<SharedServiceResponse, ObjectRequestResponse>(success: { tmp  in
            if let url = (tmp as? SharedServiceResponse)?.url {
                success?(url)
            } else {
                fail?(.string("Not url from server"))
            }
        }, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
}
