//
//  AppleGoogleLoginService.swift
//  Depo
//
//  Created by Burak Donat on 1.04.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

enum GoogleLoginOperationResult {
    case success
    case preconditionFailed
    case badRequest
}

final class AppleGoogleLoginService: BaseRequestService {
    func disconnectGoogleLogin(completion: @escaping (GoogleLoginOperationResult) -> Void) {
        debugLog("AppleGoogleLoginService disconnectGoogleLogin")

        SessionManager.customDefault
            .request(RouteRequests.googleLoginDisconnect, method: .post,
                     encoding: JSONEncoding.prettyPrinted)
            .responseString { response in
                switch response.result {
                case .success:
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 200 {
                            completion(.success)
                        } else if statusCode == 412 {
                            completion(.preconditionFailed)
                        } else {
                            completion(.badRequest)
                        }
                    }
                case .failure:
                    completion(.badRequest)
                }
            }
    }
    
    func connectGoogleLogin(with idToken: String, completion: @escaping (GoogleLoginOperationResult) -> Void) {
        debugLog("AppleGoogleLoginService connectGoogleLogin")
        
        SessionManager.customDefault
            .request(RouteRequests.googleLoginConnect, method: .post,
                     encoding: idToken)
            .responseString { response in
                switch response.result {
                case .success:
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 200 {
                            completion(.success)
                        } else if statusCode == 412 {
                            completion(.preconditionFailed)
                        } else {
                            completion(.badRequest)
                        }
                    }
                case .failure:
                    completion(.badRequest)
                }
            }
    }
}

