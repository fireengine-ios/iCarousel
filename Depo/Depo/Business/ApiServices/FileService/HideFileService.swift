//
//  HideFileService.swift
//  Depo
//
//  Created by Konstantin Studilin on 13/12/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


final class HideFileService {
    
    private lazy var sessionManager: SessionManager = factory.resolve()
    
    
    func hideItems(with uuids: [String], successAction: FileOperationSucces?, failAction: FailResponse?) {
        guard
            let request = sessionManager.request(RouteRequests.FileSystem.hide,
                                                 method: .delete,
                                                 parameters: [:],
                                                 encoding: JSONEncoding.prettyPrinted).request
        else {
            failAction?(ErrorResponse.string(TextConstants.errorUnknown))
            assertionFailure("Can't create the request")
            return
        }
        
        do {
            let encodedRequest = try uuids.encode(request, with: nil)
            
            sessionManager
            .request(encodedRequest)
            .customValidate()
            .responseData(completionHandler: { response in
                switch response.result {
                case .success(_):
                    successAction?()
                case .failure(let error):
                    failAction?(ErrorResponse.error(error))
                }
            })
        } catch {
            failAction?(ErrorResponse.error(error))
            assertionFailure(error.description)
        }
    }
}
