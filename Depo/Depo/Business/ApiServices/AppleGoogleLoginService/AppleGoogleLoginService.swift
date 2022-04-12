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
    case unknown          = ""
    
    var errorMessage: String? {
        switch self {
        case .invalidToken:
            return localized(.settingsGoogleAppleInvalidToken)
        case .emailFieldEmpty:
            return localized(.settingsGoogleAppleEmptyMailError)
        case .emailIsNotMatch:
            return localized(.settingsGoogleAppleMailMatchError)
        case .passwordRequired:
            return ""
        case .unknown:
            return TextConstants.temporaryErrorOccurredTryAgainLater
        }
    }
}

enum GoogleLoginOperationResult {
    case success
    case preconditionFailed(status: GoogeLoginMessageError?)
    case badRequest(status: GoogeLoginMessageError?)
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
                            completion(.preconditionFailed(status: .unknown))
                        }
                    }
                case .failure:
                    if let data = response.data, let statusJSON = JSON(data)["status"].string {
                        for error in GoogeLoginMessageError.allCases where error.rawValue == statusJSON {
                            completion(.badRequest(status: error))
                        }
                    } else {
                        completion(.badRequest(status: .unknown))
                    }
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
                            completion(.preconditionFailed(status: .unknown))
                        }
                    }
                case .failure:
                    if let data = response.data, let statusJSON = JSON(data)["status"].string {
                        for error in GoogeLoginMessageError.allCases where error.rawValue == statusJSON {
                            completion(.badRequest(status: error))
                        }
                    } else {
                        completion(.badRequest(status: .unknown))
                    }
                }
            }
    }
}

