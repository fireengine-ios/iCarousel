//
//  AccountInfoService.swift
//  Depo
//
//  Created by Konstantin Studilin on 06/03/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import Alamofire


final class AccountInfoService {
    
    static let shared = AccountInfoService()
    
    private let sessionManager: SessionManager = factory.resolve()
    private (set) var userId = ""
    
    
    private init() {}
    
    func updateAccountInfo(completion: @escaping BoolHandler) {
        sessionManager
            .request(RouteRequests.Account.info)
            .customValidate()
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    if let json = json as? [String: Any] {
                        self.userId = json["projectId"] as? String ?? ""
                    }
                    completion(true)
                    
                case .failure(_):
                    // silence an error
                    self.userId = ""
                    completion(false)
                    return
                }
        }
    }
    
}
