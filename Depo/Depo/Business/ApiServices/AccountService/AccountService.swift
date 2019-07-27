//
//  AccountService.swift
//  Depo
//
//  Created by Alexander Gurin on 8/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol AccountServicePrl {
    func usage(success: SuccessResponse?, fail: @escaping FailResponse)
    func info(success: SuccessResponse?, fail:@escaping FailResponse)
    func permissions(handler: @escaping (ResponseResult<PermissionsResponse>) -> Void)
    func featurePacks(handler: @escaping (ResponseResult<[PackageModelResponse]>) -> Void)
    func availableOffers(handler: @escaping (ResponseResult<[PackageModelResponse]>) -> Void)
    func getFeatures(handler: @escaping (ResponseResult<FeaturesResponse>) -> Void)
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
    
    func permissions(handler: @escaping (ResponseResult<PermissionsResponse>) -> Void) {
        debugLog("AccountService permissions")
        
        sessionManager
            .request(RouteRequests.Account.Permissions.authority)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    
                    let permissions = PermissionsResponse(json: data, headerResponse: nil)
                    handler(.success(permissions))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func featurePacks(handler: @escaping (ResponseResult<[PackageModelResponse]>) -> Void) {
        debugLog("AccountService featurePacks")
        
        sessionManager
            .request(RouteRequests.Account.Permissions.featurePacks)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let offersArray = PackageModelResponse.array(from: data)
                    handler(.success(offersArray))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }

    func availableOffers(handler: @escaping (ResponseResult<[PackageModelResponse]>) -> Void) {
        debugLog("AccountService featurePacks")

        sessionManager
            .request(RouteRequests.Account.Permissions.availableOffers)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let offersArray = PackageModelResponse.array(from: data)
                    handler(.success(offersArray))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
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

    func updateUserBirthday(_ birthday: String, handler: @escaping ResponseVoid) {
        debugLog("AccountService updateBirthday")
        
        let birthdayDigits = birthday
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        
        sessionManager
            .request(RouteRequests.Account.updateBirthday,
                     method: .post,
                     encoding: birthdayDigits)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(_):
                    handler(.success(()))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
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
        let handler = BaseResponseHandler<SettingsInfoPermissionsResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
    }
    
    func switchFaceImageAllowed(parameters: FaceImageAllowedParameters, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("AccountService switchFaceImageAllowed")

        let handler = BaseResponseHandler<SettingsInfoPermissionsResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePutRequest(param: parameters, handler: handler)
    }
    
    private lazy var sessionManager: SessionManager = factory.resolve()
    
    func getSettingsInfoPermissions(handler: @escaping (ResponseResult<SettingsInfoPermissionsResponse>) -> Void) {
        debugLog("AccountService getSettingsInfoPermissions")
        
        sessionManager
            .request(RouteRequests.Account.Settings.accessInformation)
            .customValidate()
            .responseData { response in
                switch response.result {    
                case .success(let data):
                    let faceImageAllowed = SettingsInfoPermissionsResponse(json: data, headerResponse: nil)
                    handler(.success(faceImageAllowed))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func getPermissionsAllowanceInfo(handler: @escaping (ResponseResult<[SettingsPermissionsResponse]>) -> Void) {
        debugLog("AccountService getPermissionsAllowance")
        
        let url = RouteRequests.Account.Permissions.permissionsList
        sessionManager
            .request(url)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let jsonArray = JSON(data: data).array else {
                        let error = CustomErrors.serverError("\(url) not array in response")
                        assertionFailure(error.localizedDescription)
                        handler(.failed(error))
                        return
                    }
                    
                    let results = jsonArray.compactMap { SettingsPermissionsResponse(withJSON: $0) }
                   
                    handler(.success(results))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func changePermissionsAllowed(type: PermissionType, isApproved: Bool, handler: @escaping (ResponseResult<Void>) -> Void) {
        debugLog("AccountService changePermissionsAllowed")
        
        let url = RouteRequests.Account.Permissions.permissionsUpdate
        let params: [[String: Any]] = [["type": type.rawValue,
                                        "approved": isApproved]]
        
        let urlRequest = sessionManager.request(url, method: .post).request
        
        if var request = urlRequest {
            request = try! params.encode(request, with: nil)
            
            sessionManager
                .request(request)
                .customValidate()
                .responseVoid(handler)
        }
    }
    
    func changeInstapickAllowed(isInstapickAllowed: Bool, handler: @escaping (ResponseResult<SettingsInfoPermissionsResponse>) -> Void) {
        debugLog("AccountService changeInstapickAllowed")
        
        let params: [String: Any] = [SettingsInfoPermissionsJsonKeys.instapick: isInstapickAllowed]
        
        sessionManager
            .request(RouteRequests.Account.Settings.accessInformation,
                     method: .patch,
                     parameters: params,
                     encoding: JSONEncoding.prettyPrinted)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let faceImageAllowed = SettingsInfoPermissionsResponse(json: data, headerResponse: nil)
                    handler(.success(faceImageAllowed))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
     
    func changeFaceImageAndFacebookAllowed(isFaceImageAllowed: Bool, isFacebookAllowed: Bool, handler: @escaping (ResponseResult<SettingsInfoPermissionsResponse>) -> Void) {
        debugLog("AccountService changeFaceImageAllowed")
        
        let params: [String: Any] = [SettingsInfoPermissionsJsonKeys.faceImage: isFaceImageAllowed,
                                     SettingsInfoPermissionsJsonKeys.facebook: isFacebookAllowed]
        
        sessionManager
            .request(RouteRequests.Account.Settings.accessInformation,
                     method: .post,
                     parameters: params,
                     encoding: JSONEncoding.prettyPrinted)
            .customValidate()
            .responseData { response in
                switch response.result {    
                case .success(let data):
                    let faceImageAllowed = SettingsInfoPermissionsResponse(json: data, headerResponse: nil)
                    handler(.success(faceImageAllowed))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func isAllowedFacebookTags(handler: @escaping ResponseBool) {
        debugLog("AccountService isAllowedFacebookTags")
        
        sessionManager
            .request(RouteRequests.Account.Settings.facebookTaggingEnabled)
            .customValidate()
            .responseString { response in
                switch response.result {    
                case .success(let text):
                    if let isAllowed = Bool(string: text) {
                        handler(.success(isAllowed))
                    } else {
                        let error = CustomErrors.serverError(text)
                        handler(.failed(error))
                    }
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func changeFacebookTagsAllowed(isAllowed: Bool, handler: @escaping ResponseVoid) {
        debugLog("AccountService changeFacebookTagsAllowed")
        
        sessionManager
            .request(RouteRequests.Account.Settings.facebookTaggingEnabled,
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
    
    func getFeatures(handler: @escaping (ResponseResult<FeaturesResponse>) -> Void) {
        debugLog("AccountService getFeatures")
        
        sessionManager
            .request(RouteRequests.Account.Permissions.features)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let features = FeaturesResponse(json: data, headerResponse: nil)
                    handler(.success(features))
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    /// repeat is key word of Swift
    func updatePassword(oldPassword: String,
                        newPassword: String,
                        repeatPassword: String,
                        captchaId: String,
                        captchaAnswer: String,
                        handler: @escaping (ErrorResult<Void, UpdatePasswordErrors>) -> Void) {
        
        debugLog("AccountService updatePassword")
        
        let params: Parameters = ["oldPassword": oldPassword,
                                  "password": newPassword,
                                  "repeatPassword": repeatPassword]
        
        let headers: HTTPHeaders = [HeaderConstant.CaptchaId: captchaId,
                                    HeaderConstant.CaptchaAnswer: captchaAnswer]
        
        sessionManager
            .request(RouteRequests.Account.updatePassword,
                     method: .post,
                     parameters: params,
                     encoding: JSONEncoding.prettyPrinted,
                     headers: headers)
            .customValidate()
            .responseString { response in
                /// on main queue by default
                
                switch response.result {
                case .success(let text):
                    
                    /// server logic
                    if text.isEmpty {
                        handler(.success(()))
                        return
                    }
                    
                    guard
                        let data = response.data,
                        let value = JSON(data: data)["value"].string
                    else {
                        handler(.failure(.unknown))
                        return
                    }
                    
                    let backendError: UpdatePasswordErrors
                    switch value {
                    case "Existing Password does not match":
                        backendError = .invalidOldPassword
                    case "New Password and Repeated Password does not match":
                        backendError = .notMatchNewAndRepeatPassword
                    default:
                        backendError = .unknown
                    }
                    
                    handler(.failure(backendError))
                    
                case .failure(let error):
                    
                    if error.isNetworkSpecialError {
                        handler(.failure(.special(error.description)))
                        return
                    }
                    
                    guard
                        let data = response.data,
                        let status = JSON(data: data)["status"].string
                    else {
                        handler(.failure(.unknown))
                        return
                    }
                    
                    let backendError: UpdatePasswordErrors
                    switch status {
                    case "4001":
                        backendError = .invalidCaptcha
                    case "INVALID_PASSWORD":
                        backendError = .invalidNewPassword
                    default:
                        backendError = .unknown
                    }
                    
                    handler(.failure(backendError))
                }
        }
    }
    
    func updateBrandType() {
        
        var params = [String: Any]()
#if LIFEBOX
        params["brandType"] = "LIFEBOX"
#elseif LIFEDRIVE
        params["brandType"] = "LIFEDRIVE"
#endif
        
        sessionManager.request(RouteRequests.Account.Settings.settingsApi,
                               method: .post,
                               parameters: params,
                               encoding: JSONEncoding.prettyPrinted,
                               headers: RequestHeaders.authification())
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let result):
                    let resultString = String(data: result, encoding: .utf8) ?? "Error on encoding updateBrandType response"
                    debugLog(resultString)
                case .failure(let error):
                    debugLog(error.localizedDescription)
                 }
        }
    }
    
    func faqUrl(_ handler: @escaping (String) -> Void) {
        debugLog("AccountService faqUrl")
        
        sessionManager
            .request(RouteRequests.Account.getFaqUrl)
            .customValidate()
            .responseJSON(queue: .global()) { response in
                
                func errorHandler() {
                    let defaultFaqUrl = String(format: RouteRequests.faqContentUrl, Device.supportedLocale)
                    handler(defaultFaqUrl)
                }
                
                switch response.result {
                case .success(let json):
                    if let json = json as? [String: String], let faqUrl = json["value"] {
                        handler(faqUrl)
                    } else {
                        errorHandler()
                    }
                case .failure(_):
                    errorHandler()
                }
        }
    }
    
    func feedbackEmail(_ handler: @escaping (ResponseResult<FeedbackEmailResponse>) -> Void) {
        debugLog("AccountService feedbackEmail")
        
        sessionManager
            .request(RouteRequests.feedbackEmail)
            .customValidate()
            .responseData(queue: .global(), completionHandler: { response in
                switch response.result {
                case .success(let data):
                    let feedbackResponse = FeedbackEmailResponse(json: data, headerResponse: nil)
                    handler(.success(feedbackResponse))
                case .failure(let error):
                    handler(.failed(error))
                }
            })
    }
}
