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

enum AppleGoogeLoginError: String, CaseIterable {
    case invalidToken          = "INVALID_TOKEN"
    case emailFieldEmpty       = "EMAIL_FIELD_IS_EMPTY"
    case emailIsNotMatch       = "EMAIL_IS_NOT_MATCH"
    case passwordRequired      = "PASSWORD_REQUIRED"
    case emailDomainNotAllowed = "EMAIL_DOMAIN_IS_NOT_ALLOWED"
    case appleInvalidToken     = "APPLE_TOKEN_IS_INVALID"
    case unknown               = ""
    
    var errorMessage: String? {
        switch self {
        case .invalidToken, .appleInvalidToken:
            return localized(.settingsGoogleAppleInvalidToken)
        case .emailFieldEmpty:
            return localized(.settingsGoogleAppleEmptyMailError)
        case .emailIsNotMatch:
            return localized(.settingsGoogleAppleMailMatchError)
        case .passwordRequired:
            return ""
        case .emailDomainNotAllowed:
            return localized(.emailDomainNotAllowed)
        case .unknown:
            return TextConstants.temporaryErrorOccurredTryAgainLater
        }
    }
}

enum GoogleLoginOperationResult {
    case success
    case preconditionFailed(status: AppleGoogeLoginError?)
    case badRequest(status: AppleGoogeLoginError?)
}

typealias AppleGoogleUserCompletion = (_ user: AppleGoogleUser? ) -> Void

final class AppleGoogleLoginService: BaseRequestService {
    
    private let decoder = JWTTokenDecoder.shared

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
                            for error in AppleGoogeLoginError.allCases where error.rawValue == statusJSON {
                                completion(.preconditionFailed(status: error))
                            }
                        } else {
                            completion(.preconditionFailed(status: .unknown))
                        }
                    }
                case .failure:
                    if let data = response.data, let statusJSON = JSON(data)["status"].string {
                        for error in AppleGoogeLoginError.allCases where error.rawValue == statusJSON {
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
                            for error in AppleGoogeLoginError.allCases where error.rawValue == statusJSON {
                                completion(.preconditionFailed(status: error))
                            }
                        } else {
                            completion(.preconditionFailed(status: .unknown))
                        }
                    }
                case .failure:
                    if let data = response.data, let statusJSON = JSON(data)["status"].string {
                        for error in AppleGoogeLoginError.allCases where error.rawValue == statusJSON {
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
        
        guard let email = decoder.decode(jwtToken: idTokenString)["email"] as? String else {
            fail("Unable to decode email string from idToken: \(idTokenString)")
            return
        }
        
        let user = AppleGoogleUser(idToken: idTokenString, email: email, type: .apple)
        success(user)
        
    }
    
    func getAppleAuthorizationController() -> ASAuthorizationController {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        return ASAuthorizationController(authorizationRequests: [request])
    }
}

