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
    
    
    func hide(items: [WrapData], handler: @escaping ResponseVoid) {
        
        let request = sessionManager.request(RouteRequests.FileSystem.hide,
                               method: .delete,
                               parameters: [:],
                               encoding: JSONEncoding.prettyPrinted)
        
        sessionManager
            .request(request)
            .customValidate()
            .responseData(completionHandler: { response in
                switch response.result {
                case .success(let data):
                    handler(.success(()))
                case .failure(let error):
                    handler(.failed(error))
                }
            })
    }
}
