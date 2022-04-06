//
//  AppleGoogleLoginService.swift
//  Depo
//
//  Created by Burak Donat on 1.04.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum GoogeLoginMessageError: String, CaseIterable {
    case invalidToken     = "INVALID_TOKEN"
    case emailFieldEmpty  = "EMAIL_FIELD_IS_EMPTY"
    case emailIsNotMatch  = "EMAIL_IS_NOT_MATCH"
    case passwordRequired = "PASSWORD_REQUIRED"
    case defaultError     = ""
    
    var errorMessage: String? {
        switch self {
        case .invalidToken:
            return ""
        case .emailFieldEmpty:
            return ""
        case .emailIsNotMatch:
            return ""
        case .passwordRequired:
            return ""
        case .defaultError:
            return TextConstants.temporaryErrorOccurredTryAgainLater
        }
    }
}

enum GoogleLoginOperationResult {
    case success
    case preconditionFailed(status: GoogeLoginMessageError?)
    case badRequest
}

final class AppleGoogleLoginService: BaseRequestService {
    func disconnectGoogleLogin(completion: @escaping (GoogleLoginOperationResult) -> Void) {
        debugLog("AppleGoogleLoginService disconnectGoogleLogin")
        
        SessionManager.customDefault
            .request(RouteRequests.googleLoginDisconnect,
                     method: .post,
                     encoding: JSONEncoding.prettyPrinted)
            .responseString { response in
                switch response.result {
                case .success:
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 200 {
                            completion(.success)
                        } else if let data = response.data, let statusJSON = JSON(data)["status"].string {
                            for error in GoogeLoginMessageError.allCases where error.rawValue == statusJSON {
                                completion(.preconditionFailed(status: error))
                            }
                        } else {
                            completion(.preconditionFailed(status: .defaultError))
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
            .request(RouteRequests.googleLoginConnect,
                     method: .post,
                     encoding: idToken)
            .responseString { response in
                switch response.result {
                case .success:
                    if let statusCode = response.response?.statusCode {
                        if statusCode == 200 {
                            completion(.success)
                        } else if let data = response.data, let statusJSON = JSON(data)["status"].string {
                            for error in GoogeLoginMessageError.allCases where error.rawValue == statusJSON {
                                completion(.preconditionFailed(status: error))
                            }
                        } else {
                            completion(.preconditionFailed(status: .defaultError))
                        }
                    }
                case .failure:
                    completion(.badRequest)
                }
            }
    }
}

