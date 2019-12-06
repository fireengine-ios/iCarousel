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
    func autoSyncStatus(syncSettings : AutoSyncSettings? , handler: @escaping ResponseVoid)
}

class AccountService: BaseRequestService, AccountServicePrl {
    
    private enum Keys {
        static let serverValue = "value"
    }
 
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
    
    func securitySettingsInfo(success: SuccessResponse?, fail: FailResponse?) {
        debugLog("AccountService securitySettingsInfo")

        let parametres = SecuritySettingsInfoParametres()
        let handler = BaseResponseHandler<SecuritySettingsInfoResponse, SignUpFailResponse>(success: success, fail: fail)
        executeGetRequest(param: parametres, handler: handler)
    }
    
    func securitySettingsChange(turkcellPasswordAuthEnabled: Bool,
                                mobileNetworkAuthEnabled: Bool,
                                twoFactorAuthEnabled: Bool,
                                success: SuccessResponse?,
                                fail: FailResponse?) {
        debugLog("AccountService securitySettingsChange")
        
        let parametres = SecuritySettingsChangeInfoParametres(turkcellPasswordAuth: turkcellPasswordAuthEnabled,
                                                              mobileNetworkAuth: mobileNetworkAuthEnabled,
                                                              twoFactorAuth: twoFactorAuthEnabled)
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
    
    func autoSyncStatus(syncSettings : AutoSyncSettings? , handler: @escaping ResponseVoid) {
        debugLog("AccountService autoSyncStatus")
        
        let settings: AutoSyncSettings = syncSettings ?? AutoSyncDataStorage().settings
        
        let photoStatus : String = settings.isAutoSyncEnabled ? settings.photoSetting.option.rawValue : AutoSyncOption.never.rawValue
        let videoStatus : String = settings.isAutoSyncEnabled ? settings.videoSetting.option.rawValue : AutoSyncOption.never.rawValue
        
        let params: Parameters  = [ "photoStatus" : photoStatus , "videoStatus" : videoStatus]
        
        sessionManager
            .request(RouteRequests.Account.Settings.autoSyncStatus,
                     method: .post,
                     parameters: params,
                     encoding: JSONEncoding.prettyPrinted
        )
            .customValidate()
            .response { response in
                if response.response?.statusCode == 200 {
                    handler(.success(()))
                } else if let data = response.data, let statusJSON = JSON(data: data)["status"].string {
                    let errorText: String
                    
                    if statusJSON == "ACCOUNT_NOT_FOUND" {
                        errorText = TextConstants.noAccountFound
                    } else if statusJSON == "EMPTY_REQUEST" {
                        errorText = "EMPTY_REQUEST" ///Should add localized text?
                    } else {
                        errorText = TextConstants.errorServer
                    }
                    
                    let error = CustomErrors.text(errorText)
                    handler(.failed(error))
                } else {
                    let error = CustomErrors.text(TextConstants.errorServer)
                    handler(.failed(error))
                }
        }
        
    }
    
    func getListOfSecretQuestions(handler: @escaping (ResponseResult<[SecretQuestionsResponse]>) -> Void) {
        let request = String(format: RouteRequests.Account.getSecurityQuestion.absoluteString, Device.supportedLocale)
        
        sessionManager
            .request(request)
            .customValidate()
            .responseData(completionHandler: { response in

                switch response.result {
                    
                case .success(let data):
                    
                    let questions = JSON(data)[Keys.serverValue].arrayValue.compactMap { SecretQuestionsResponse(json: $0)}
                    handler(.success(questions))
                case .failure(let error):
                    handler(.failed(error))
                }
            })
    }
    
    func updateSecurityQuestion(questionId: Int,
                                securityQuestionAnswer: String,
                                captchaId: String,
                                captchaAnswer: String,
                                handler: @escaping (ErrorResult<Void, SetSecretQuestionErrors>) -> Void) {
        
        let headers: HTTPHeaders = [HeaderConstant.CaptchaId: captchaId,
                                    HeaderConstant.CaptchaAnswer: captchaAnswer]
        let params: Parameters = ["securityQuestionId": questionId,
                                  "securityQuestionAnswer": securityQuestionAnswer]
        
        sessionManager
            .request(RouteRequests.Account.updateSecurityQuestion,
                     method: .post,
                     parameters: params,
                     encoding: JSONEncoding.prettyPrinted,
                     headers: headers)
            .customValidate()
            .response { response in
                if response.response?.statusCode == 200 {
                    handler(.success(()))
                } else if let data = response.data, let status = JSON(data: data)["status"].string {
                    
                    let backendError: SetSecretQuestionErrors
                    switch status {
                    case "4001":
                        backendError = .invalidCaptcha
                    case "SEQURITY_QUESTION_ID_IS_INVALID":
                        backendError = .invalidId
                    case "SEQURITY_QUESTION_ANSWER_IS_INVALID":
                        backendError = .invalidAnswer
                    default:
                        backendError = .unknown
                    }
                    handler(.failure(backendError))
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
                                  "repeatPassword": repeatPassword,
                                  "passwordRuleSetVersion": NumericConstants.passwordRuleSetVersion]
        
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
                    
                    guard let data = response.data, let value = JSON(data: data)["value"].string else {
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
                   
                    guard let data = response.data else {
                        handler(.failure(.unknown))
                        return
                    }
                    
                    let errorResponse = UpdatePasswordErrorResponse(json: JSON(data: data))
                    
                    
                    if errorResponse.status == .invalidCaptcha {
                        handler(.failure(.invalidCaptcha))
                    } else if errorResponse.status == .invalidPassword {
                        
                        guard let reason = errorResponse.reason else {
                            handler(.failure(.invalidNewPassword))
                            return
                        }
                        
                        let backendError: UpdatePasswordErrors
                        
                        switch reason {
                        case .passwordIsEmpty:
                            backendError = .passwordIsEmpty
                        case .sequentialCharacters:
                            backendError = .passwordSequentialCaharacters(limit: errorResponse.sequentialCharacterLimit)
                        case .sameCharacters:
                            backendError = .passwordSameCaharacters(limit: errorResponse.sameCharacterLimit)
                        case .passwordLengthExceeded:
                            backendError = .passwordLengthExceeded(limit: errorResponse.maximumCharacterLimit)
                        case .passwordLengthIsBelowLimit:
                            backendError = .passwordLengthIsBelowLimit(limit: errorResponse.minimumCharacterLimit)
                        case .resentPassword:
                            backendError = .passwordInResentHistory(limit: errorResponse.recentHistoryLimit)
                        case .uppercaseMissing:
                            backendError = .uppercaseMissingInPassword
                        case .lowercaseMissing:
                            backendError = .lowercaseMissingInPassword
                        case .numberMissing:
                            backendError = .numberMissingInPassword
                        }
                        
                        handler(.failure(backendError))
                        
                    } else {
                       handler(.failure(.unknown))
                    }
                }
        }
    }
    
    func updateBrandType() {
        
        var params = [String: Any]()
#if LIFEBOX
        params["brandType"] = "LIFEBOX"
#elseif LIFEDRIVE
        params["brandType"] = "BILLO"
#endif
        
        sessionManager.request(RouteRequests.Account.Settings.settingsApi,
                               method: .patch,
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
        
        SessionManager.sessionWithoutAuth
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
    
    func verifyEmail(otpCode: String, handler: @escaping ResponseVoid) {
        sessionManager
            .request(RouteRequests.verifyEmail,
                     method: .post,
                     parameters: ["otp" : otpCode],
                     encoding: JSONEncoding.prettyPrinted)
            .customValidate()
            .response(queue: .global(), completionHandler: { response in
                if response.response?.statusCode == 200 {
                    handler(.success(()))
                } else if let data = response.data, let statusJSON = JSON(data: data)["status"].string {
                    let errorText: String
                    
                    if statusJSON == "INVALID_OTP" {
                        errorText = TextConstants.invalidOTP
                        
                    } else if statusJSON == "TOO_MANY_REQUESTS" {
                        errorText = TextConstants.tooManyRequests
                        
                    } else if statusJSON == "EXPIRED_OTP" {
                        errorText = TextConstants.expiredOTP
                        
                    } else if statusJSON == "REFERENCE_TOKEN_IS_EMPTY" {
                        errorText = TextConstants.tokenIsMissing
                        
                    } else if statusJSON == "ACCOUNT_NOT_FOUND" {
                        errorText = TextConstants.noAccountFound
                        
                    } else if statusJSON == "INVALID_EMAIL" {
                        errorText = TextConstants.invalidEmail
                        
                    } else {
                        errorText = TextConstants.errorServer
                    }
                    
                    let error = CustomErrors.text(errorText)
                    handler(.failed(error))
                } else {
                    let error = CustomErrors.text(TextConstants.errorServer)
                    handler(.failed(error))
                }
            })
    }
    
    func sendEmailVerificationCode(handler: @escaping ResponseVoid) {
        sessionManager
            .request(RouteRequests.sendEmailVerificationCode,
                     method: .post,
                     parameters: nil,
                     encoding: JSONEncoding.prettyPrinted)
            .customValidate()
            .response(queue: .global(), completionHandler: { response in
                if response.response?.statusCode == 200 {
                    handler(.success(()))
                } else if let data = response.data, let statusJSON = JSON(data: data)["status"].string {
                    let errorText: String
                    
                    if statusJSON == "ACCOUNT_NOT_FOUND" {
                        errorText = TextConstants.invalidOTP
                        
                    } else if statusJSON == "TOO_MANY_REQUESTS" {
                        errorText = TextConstants.tooManyRequests
                        
                    } else {
                        errorText = TextConstants.errorServer
                    }
                    
                    let error = CustomErrors.text(errorText)
                    handler(.failed(error))
                } else {
                    let error = CustomErrors.text(TextConstants.errorServer)
                    handler(.failed(error))
                }
            })
    }
    
    func updateAddress(with address: String, handler: @escaping ResponseVoid) {
        sessionManager
            .request(RouteRequests.Account.updateAddress,
                 method: .post,
                 parameters: ["address": address],
                 encoding: JSONEncoding.prettyPrinted)
        .customValidate()
        .response(queue: .global(), completionHandler: { response in
            if response.response?.statusCode == 200 {
                handler(.success(()))
            } else if let data = response.data, let status = JSON(data: data)["status"].string {
                let errorText: String
                
                if status == "ACCOUNT_ADDRESS_LENGTH_IS_INVALID" {
                    errorText = TextConstants.updateAddressError
                } else {
                    errorText = TextConstants.errorServer
                }
                
                let error = CustomErrors.text(errorText)
                handler(.failed(error))
            } else {
                let error = CustomErrors.text(TextConstants.errorServer)
                handler(.failed(error))
            }
        })

    }
}
