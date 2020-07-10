//
//  PrivacyPolicyService.swift
//  Depo
//
//  Created by Maxim Soldatov on 2/6/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Alamofire
import SwiftyJSON

protocol PrivacyPolicyService {
    func getPrivacyPolicy(completion: @escaping ((ResponseResult<PrivacyPolicyResponse>) -> Void))
}

final class PrivacyPolicyServiceImp: BaseRequestService, PrivacyPolicyService {

    private let sessionManager: SessionManager
    
    required init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
    
    func getPrivacyPolicy(completion: @escaping (ResponseResult<PrivacyPolicyResponse>) -> Void) {
        sessionManager
            .request(RouteRequests.privacyPolicy)
            .customValidate().responseData { response in
                switch response.result {
                case .success(let data):
                    
                    guard let response = PrivacyPolicyResponse(json: JSON(data: data)) else {
                        assertionFailure()
                        return
                    }
                
                    completion(.success(response))
                case .failure(let error):
                    completion(.failed(error))
                }
        }
    }
    
}
