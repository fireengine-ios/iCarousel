//
//  AccountService.swift
//  Depo
//
//  Created by Alexander Gurin on 8/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import Alamofire

protocol AccountServicePrl {
    func usage(success: SuccessResponse?, fail: @escaping FailResponse)
    func info(success: SuccessResponse?, fail:@escaping FailResponse)
}

class AccountService: BaseRequestService, AccountServicePrl {
    
    func info(success: SuccessResponse?, fail:@escaping FailResponse) {
        debugLog("AccountService info")
        
        let param = AccontInfo()
        let handler = BaseResponseHandler<AccountInfoResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func quotaInfo(success: SuccessResponse?, fail:@escaping FailResponse) {
        debugLog("AccountService quotaInfo")

        let param = QuotaInfo()
        let handler = BaseResponseHandler<QuotaInfoResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func usage(success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("AccountService usage")

        let param = UsageParameters()
        let handler = BaseResponseHandler<UsageResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func provision() {
        
    }
    
    func language(success: SuccessResponse?, fail:@escaping FailResponse) {
        debugLog("AccountService language")

        let param = LanguageList()
        let handler = BaseResponseHandler<LanguageListResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    func updateLanguage(success: SuccessResponse?, fail:@escaping FailResponse) {
        debugLog("AccountService updateLanguage")

        let param = LanguageListChange()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
    
    
    // MARK: Profile photo
    
    func setProfilePhoto(param: UserPhoto, success: SuccessResponse?, fail:@escaping FailResponse) {
        debugLog("AccountService setProfilePhoto")

        let handler = BaseResponseHandler<UserPhotoResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePutRequest(param: param, handler: handler)
    }
    
    func deleteProfilePhoto(success: SuccessResponse?, fail:@escaping FailResponse) {
        debugLog("AccountService deleteProfilePhoto")

        let param = UserPhoto()
        let handler = BaseResponseHandler<UserPhotoResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeDeleteRequest(param: param, handler: handler)
    }
    
    // MARK: - User Profile

    func updateUserProfile(parameters: UserNameParameters, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("AccountService updateUserProfile")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: parameters, handler: handler)
    }
    
    func updateUserEmail(parameters: UserEmailParameters, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("AccountService updateUserEmail")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: parameters, handler: handler)
    }
    
    func updateUserPhone(parameters: UserPhoneNumberParameters, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("AccountService updateUserPhone")

        let handler = BaseResponseHandler<SignUpSuccessResponse, SignUpFailResponse>(success: success, fail: fail)
        executePostRequest(param: parameters, handler: handler)
    }
    
    func verifyPhoneNumber(parameters: VerifyPhoneNumberParameter, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("AccountService verifyPhoneNumber")

        let handler = BaseResponseHandler<SignUpSuccessResponse, SignUpFailResponse>(success: success, fail: fail)
        executePostRequest(param: parameters, handler: handler)
    }
    
    // MARK: - User Security
    
    func securitySettingsInfo(success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("AccountService securitySettingsInfo")

        let parametres = SecuritySettingsInfoParametres()
        let handler = BaseResponseHandler<SecuritySettingsInfoResponse, SignUpFailResponse>(success: success, fail: fail)
        executeGetRequest(param: parametres, handler: handler)
    }
    
    func securitySettingsChange(turkcellPasswordAuthEnabled: Bool? = nil, mobileNetworkAuthEnabled: Bool? = nil,
                                success: SuccessResponse?, fail: FailResponse?) {
        debugLog("AccountService securitySettingsChange")
        
        let parametres = SecuritySettingsChangeInfoParametres(turkcellPasswordAuth: turkcellPasswordAuthEnabled ?? false,
                                                              mobileNetworkAuth: mobileNetworkAuthEnabled ?? false)
        let handler = BaseResponseHandler<SecuritySettingsInfoResponse, SignUpFailResponse>(success: success, fail: fail)
        executePostRequest(param: parametres, handler: handler)
    }
    
    // MARK: - Face Image Allowed
    func faceImageAllowed(success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("AccountService faceImageAllowed")
        
        let parameters = FaceImageAllowedParameters()
        let handler = BaseResponseHandler<FaceImageAllowedResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
    }
    
    func switchFaceImageAllowed(parameters: FaceImageAllowedParameters, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("AccountService switchFaceImageAllowed")

        let handler = BaseResponseHandler<FaceImageAllowedResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePutRequest(param: parameters, handler: handler)
    }
    
    private lazy var sessionManager: SessionManager = factory.resolve()
    
    func isAllowedFaceImage(handler: @escaping ResponseBool) {
        debugLog("AccountService faceImageIsAllowed")
        
        sessionManager
            .request(RouteRequests.Account.Settings.faceImageAllowed)
            .customValidate()
            .responseString { response in
                switch response.result {    
                case .success(let text):
                    if text == "true" {
                        handler(.success(true))
                    } else if text == "false" {
                        handler(.success(false))
                    } else {
                        let error = CustomErrors.serverError(text)
                        handler(.failed(error))
                    }
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
     
    func changeFaceImageAllowed(isAllowed: Bool, handler: @escaping ResponseVoid) {
        debugLog("AccountService changeFaceImageAllowed")
        
        sessionManager
            .request(RouteRequests.Account.Settings.faceImageAllowed,
                     method: .put,
                     encoding: String(isAllowed))
            .customValidate()
            .responseString { response in
                switch response.result {    
                case .success(let text):
                    if text == "\"OK\"" {
                        handler(.success(()))
                    } else {
                        let error = CustomErrors.serverError(text)
                        handler(.failed(error))
                    }
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
}
