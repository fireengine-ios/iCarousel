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
import AuthenticationServices

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

typealias AppleGoogleUserCompletion = (_ user: AppleGoogleUser? ) -> Void

final class AppleGoogleLoginService: BaseRequestService {
    func disconnectAppleGoogleLogin(type: AppleGoogleUserType, completion: @escaping (GoogleLoginOperationResult) -> Void) {
        debugLog("AppleGoogleLoginService disconnectAppleGoogleLogin")
        
        let path = type == .google ? RouteRequests.googleLoginDisconnect : RouteRequests.appleLoginDisconnect
        
        SessionManager.customDefault
            .request(path,
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
    
    func connectAppleGoogleLogin(with user: AppleGoogleUser, completion: @escaping (GoogleLoginOperationResult) -> Void) {
        debugLog("AppleGoogleLoginService connectAppleGoogleLogin")
        
        let path = user.type == .google ? RouteRequests.googleLoginConnect : RouteRequests.appleLoginConnect
        
        SessionManager.customDefault
            .request(path,
                     method: .post,
                     encoding: user.idToken)
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

@available(iOS 13.0, *)
extension AppleGoogleLoginService {
    func getAppleCredentials(with credentials: ASAuthorizationAppleIDCredential, success: AppleGoogleUserCompletion, fail: (String) -> Void ) {
        guard let appleIDToken = credentials.identityToken else {
            fail("Unable to fetch identity token")
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            fail("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        
        var user = AppleGoogleUser(idToken: idTokenString, email: credentials.email, type: .apple)
        
        if credentials.email != nil { ///save apple login email into Keychain
            tokenStorage.appleLoginEmail = credentials.email
        } else {
            user.email = tokenStorage.appleLoginEmail
        }
        
        success(user)
    }
    
    func getAppleAuthorizationController() -> ASAuthorizationController {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        return ASAuthorizationController(authorizationRequests: [request])
    }
}

