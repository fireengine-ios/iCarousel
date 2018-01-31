//
//  AccountService.swift
//  Depo
//
//  Created by Alexander Gurin on 8/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

protocol AccountServicePrl {
    func usage(success: SuccessResponse?, fail: @escaping FailResponse)
    func info(success: SuccessResponse?, fail:@escaping FailResponse)
}

class AccountService: BaseRequestService, AccountServicePrl {
    
    func info(success: SuccessResponse?, fail:@escaping FailResponse) {
        log.debug("AccountService info")
        
        let param = AccontInfo()
        let handler = BaseResponseHandler<AccountInfoResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func quotaInfo(success: SuccessResponse?, fail:@escaping FailResponse) {
        log.debug("AccountService quotaInfo")

        let param = QuotaInfo()
        let handler = BaseResponseHandler<QuotaInfoResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func usage(success: SuccessResponse?, fail: @escaping FailResponse) {
        log.debug("AccountService usage")

        let param = UsageParameters()
        let handler = BaseResponseHandler<UsageResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func provision() {
        
    }
    
    func language(success: SuccessResponse?, fail:@escaping FailResponse) {
        log.debug("AccountService language")

        let param = LanguageList()
        let handler = BaseResponseHandler<LanguageListResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    func updateLanguage(success: SuccessResponse?, fail:@escaping FailResponse) {
        log.debug("AccountService updateLanguage")

        let param = LanguageListChange()
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
    
    
    // MARK: Profile photo
    
    func setProfilePhoto(param: UserPhoto, success: SuccessResponse?, fail:@escaping FailResponse) {
        log.debug("AccountService setProfilePhoto")

        let handler = BaseResponseHandler<UserPhotoResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePutRequest(param: param, handler: handler)
    }
    
    func deleteProfilePhoto(success: SuccessResponse?, fail:@escaping FailResponse) {
        log.debug("AccountService deleteProfilePhoto")

        let param = UserPhoto()
        let handler = BaseResponseHandler<UserPhotoResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeDeleteRequest(param: param, handler: handler)
    }
    
    //MARK: - User Profile

    func updateUserProfile(parameters: UserNameParameters, success: SuccessResponse?, fail: @escaping FailResponse) {
        log.debug("AccountService updateUserProfile")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: parameters, handler: handler)
    }
    
    func updateUserEmail(parameters: UserEmailParameters, success: SuccessResponse?, fail: @escaping FailResponse) {
        log.debug("AccountService updateUserEmail")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: parameters, handler: handler)
    }
    
    func updateUserPhone(parameters: UserPhoneNumberParameters, success: SuccessResponse?, fail: @escaping FailResponse) {
        log.debug("AccountService updateUserPhone")

        let handler = BaseResponseHandler<SignUpSuccessResponse, SignUpFailResponse>(success: success, fail: fail)
        executePostRequest(param: parameters, handler: handler)
    }
    
    func verifyPhoneNumber(parameters: VerifyPhoneNumberParameter, success: SuccessResponse?, fail: @escaping FailResponse) {
        log.debug("AccountService verifyPhoneNumber")

        let handler = BaseResponseHandler<SignUpSuccessResponse, SignUpFailResponse>(success: success, fail: fail)
        executePostRequest(param: parameters, handler: handler)
    }
    
    //MARK: - User Security
    
    func securitySettingsInfo(success: SuccessResponse?, fail: @escaping FailResponse) {
        log.debug("AccountService securitySettingsInfo")

        let parametres = SecuritySettingsInfoParametres()
        let handler = BaseResponseHandler<SecuritySettingsInfoResponse, SignUpFailResponse>(success: success, fail: fail)
        executeGetRequest(param: parametres, handler: handler)
    }
    
    func securitySettingsChange(turkcellPasswordAuthEnabled: Bool? = nil, mobileNetworkAuthEnabled: Bool? = nil,
                                success: SuccessResponse?, fail: FailResponse?) {
        log.debug("AccountService securitySettingsChange")
        
        let parametres = SecuritySettingsChangeInfoParametres(turkcellPasswordAuth: turkcellPasswordAuthEnabled ?? false,
                                                              mobileNetworkAuth: mobileNetworkAuthEnabled ?? false)
        let handler = BaseResponseHandler<SecuritySettingsInfoResponse, SignUpFailResponse>(success: success, fail: fail)
        executePostRequest(param: parametres, handler: handler)
    }
    
    //MARK: - Face Image Allowed
    func faceImageAllowed(success: SuccessResponse?, fail: @escaping FailResponse) {
        log.debug("AccountService faceImageAllowed")
        
        let parameters = FaceImageAllowedParameters()
        let handler = BaseResponseHandler<FaceImageAllowedResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
    }
    
    func switchFaceImageAllowed(parameters: FaceImageAllowedParameters, success: SuccessResponse?, fail: @escaping FailResponse) {
        log.debug("AccountService switchFaceImageAllowed")

        let handler = BaseResponseHandler<FaceImageAllowedResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePutRequest(param: parameters, handler: handler)
    }
}
