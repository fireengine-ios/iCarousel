//
//  QRCodeService.swift
//  Lifebox
//
//  Created by Ozan Salman on 17.01.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

final class QRCodeService: BaseRequestService {
    
    @discardableResult
    func readQRCode(referenceToken: String, handler: @escaping ResponseHandler<QRCodeResponse>) -> URLSessionTask? {
        debugLog("readQRCode")
        
        let parameters: [String: Any] = ["referenceToken": referenceToken]
        
        return SessionManager
            .customDefault
            .request(RouteRequests.readQrCode,
                     method: .post,
                     parameters: parameters,
                     encoding: JSONEncoding.default)
            .customValidate()
            .responseObject(handler)
            .task
    }
}
