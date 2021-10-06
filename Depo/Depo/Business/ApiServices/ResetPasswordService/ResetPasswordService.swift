//
//  ResetPasswordService.swift
//  Depo
//
//  Created by Hady on 9/20/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

protocol ResetPasswordServiceProtocol {
    var isInSecondChallenge: Bool { get }

    func beginResetFlow(with params: ForgotPasswordV2)
    func proceedVerification(with method: IdentityVerificationMethod)
    func sendOTP()
    func verifyOTP(code: String)
    func validateSecurityQuestion(id: Int, answer: String)
    func reset(newPassword: String)
}

final class ResetPasswordService: BaseRequestService, ResetPasswordServiceProtocol {
    typealias ResponseCompletion<R> = (Swift.Result<R, Error>) -> Void

    weak var delegate: ResetPasswordServiceDelegate?

    private let sessionManager = SessionManager.customDefault
    private var referenceToken: String?
    private(set) var isInSecondChallenge: Bool = false

    func beginResetFlow(with params: ForgotPasswordV2) {
        callForgotMyPassword(params: params) { result in
            switch result {
            case let .success(response):
                self.handleFirstResponse(response)

            case let .failure(error):
                self.delegate?.resetPasswordService(self, receivedError: error)
            }
        }
    }

    func proceedVerification(with method: IdentityVerificationMethod) {
        guard let referenceToken = self.referenceToken else {
            return
        }

        switch method {
        case .email:
            proceedWithEmail(referenceToken: referenceToken) { result in
                switch result {
                case .success:
                    self.delegate?.resetPasswordService(self, readyToProceedWithMethod: method)
                case let .failure(error):
                    self.delegate?.resetPasswordService(self, receivedError: error)
                }
            }

        case .recoveryEmail:
            proceedWithRecoveryEmail(referenceToken: referenceToken) { result in
                switch result {
                case .success:
                    self.delegate?.resetPasswordService(self, readyToProceedWithMethod: method)
                case let .failure(error):
                    self.delegate?.resetPasswordService(self, receivedError: error)
                }
            }

        case .sms,
             .securityQuestion:
            delegate?.resetPasswordService(self, readyToProceedWithMethod: method)

        case .unknown:
            debugLog("unknown method \(method)")
        }
    }

    func sendOTP() {
        guard let referenceToken = self.referenceToken else { return }
        callSendSMS(referenceToken: referenceToken) { result in
            switch result {
            case let .success(response):
                self.referenceToken = response.referenceToken
                self.delegate?.resetPasswordService(self, receivedOTPResponse: response)
            case let .failure(error):
                self.delegate?.resetPasswordService(self, receivedError: error)
            }
        }
    }

    func verifyOTP(code: String) {
        guard let referenceToken = self.referenceToken else { return }
        callValidatePhoneNumber(referenceToken: referenceToken, otp: code) { result in
            switch result {
            case .success:
                self.checkStatusAfterPhoneVerification(referenceToken: referenceToken)

            case let .failure(error):
                self.delegate?.resetPasswordService(self, receivedError: error)
            }
        }
    }

    func validateSecurityQuestion(id: Int, answer: String) {
        guard let referenceToken = self.referenceToken else { return }
        callValidateSecurityQuestion(referenceToken: referenceToken, questionId: id, answer: answer) { result in
            switch result {
            case .success:
                self.delegate?.resetPasswordServiceVerifiedSecurityQuestion(self)
            case let .failure(error):
                self.delegate?.resetPasswordService(self, receivedError: error)
            }
        }
    }

    func reset(newPassword: String) {
        guard let referenceToken = self.referenceToken else { return }
        callChangePassword(referenceToken: referenceToken, newPassword: newPassword) { result in
            switch result {
            case .success:
                self.delegate?.resetPasswordServiceChangedPasswordSuccessfully(self)
            case let .failure(error):
                self.delegate?.resetPasswordService(self, receivedError: error)
            }
        }
    }

    private func handleFirstResponse(_ response: ResetPasswordResponse) {
        referenceToken = response.referenceToken
        delegate?.resetPasswordService(self, resetBeganWithMethods: response.methods)
    }

    private func proceedWithEmail(referenceToken: String, completion: @escaping ResponseCompletion<Void>) {
        if isInSecondChallenge {
            callContinueWithEmail(referenceToken: referenceToken, completion: completion)
        } else {
            callSendEmail(referenceToken: referenceToken, completion: completion)
        }
    }

    private func proceedWithRecoveryEmail(referenceToken: String, completion: @escaping ResponseCompletion<Void>) {
        if isInSecondChallenge {
            callContinueWithRecoveryEmail(referenceToken: referenceToken, completion: completion)
        } else {
            callSendRecoveryEmail(referenceToken: referenceToken, completion: completion)
        }
    }

    private func checkStatusAfterPhoneVerification(referenceToken: String) {
        callCheckStatus(referenceToken: referenceToken) { result in
            switch result {
            case let .success(response):
                self.isInSecondChallenge = true
                self.referenceToken = response.referenceToken
                self.delegate?.resetPasswordService(self, phoneVerified: response.methods)
            case let .failure(error):
                self.delegate?.resetPasswordService(self, receivedError: error)
            }
        }
    }
}

// MARK: - API Calls
private extension ResetPasswordService {
    func callForgotMyPassword(params: ForgotPasswordV2,
                              completion: @escaping ResponseCompletion<ResetPasswordResponse>) {
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { legacyResponse in
            do {
                let response = try legacyResponse.decodedResponse(ResetPasswordResponse.self)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        } fail: { error in
            completion(.failure(error))
        }

        executePostRequest(param: params, handler: handler)
    }
    
    func callSendEmail(referenceToken: String, completion: @escaping ResponseCompletion<Void>) {
        let param = TokenInBody(token: referenceToken, url: RouteRequests.ForgotMyPassword.sendEmail)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { _ in
            completion(.success(()))
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }

    func callSendRecoveryEmail(referenceToken: String, completion: @escaping ResponseCompletion<Void>) {
        let param = TokenInBody(token: referenceToken, url: RouteRequests.ForgotMyPassword.sendRecoveryEmail)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { _ in
            completion(.success(()))
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }

    func callSendSMS(referenceToken: String, completion: @escaping ResponseCompletion<ResetPasswordResponse>) {
        let param = TokenInBody(token: referenceToken, url: RouteRequests.ForgotMyPassword.sendSMS)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { legacyResponse in
            do {
                let response = try legacyResponse.decodedResponse(ResetPasswordResponse.self)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }

    func callValidatePhoneNumber(referenceToken: String, otp: String, completion: @escaping ResponseCompletion<Void>) {
        let param = ValidatePhoneNumber(token: referenceToken, otp: otp)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { _ in
            completion(.success(()))
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }

    func callCheckStatus(referenceToken: String, completion: @escaping ResponseCompletion<ResetPasswordResponse>) {
        let param = TokenInBody(token: referenceToken, url: RouteRequests.ForgotMyPassword.checkStatus)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { legacyResponse in
            do {
                let response = try legacyResponse.decodedResponse(ResetPasswordResponse.self)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }

    func callContinueWithEmail(referenceToken: String, completion: @escaping ResponseCompletion<Void>) {
        let param = TokenInBody(token: referenceToken, url: RouteRequests.ForgotMyPassword.continueWithEmail)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { _ in
            completion(.success(()))
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }

    func callContinueWithRecoveryEmail(referenceToken: String, completion: @escaping ResponseCompletion<Void>) {
        let param = TokenInBody(token: referenceToken, url: RouteRequests.ForgotMyPassword.continueWithRecoveryEmail)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { _ in
            completion(.success(()))
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }

    func callValidateSecurityQuestion(referenceToken: String, questionId: Int, answer: String,
                                      completion: @escaping ResponseCompletion<Void>) {
        let param = ValidateSecurityQuestion(referenceToken: referenceToken, questionId: questionId, answer: answer)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { _ in
            completion(.success(()))
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }

    func callChangePassword(referenceToken: String, newPassword: String, completion: @escaping ResponseCompletion<Void>) {
        let param = ChangePassword(referenceToken: referenceToken, password: newPassword)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { _ in
            completion(.success(()))
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }
}

// MARK: - Endpoint Param Definitions

struct ForgotPasswordV2: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }

    let email: String?
    let msisdn: String?
    let attachedCaptcha: CaptchaParametrAnswer?

    var requestParametrs: Any {
        return [
            LbRequestkeys.email: email,
            LbRequestkeys.msisdn: msisdn
        ]
    }

    var patch: URL {
        return RouteRequests.ForgotMyPassword.link
    }

    var header: RequestHeaderParametrs {
        let headers = RequestHeaders.base() + RequestHeaders.deviceUuidHeader()
        if let captcha = attachedCaptcha {
            return headers + captcha.header
        }
        return headers
    }
}

private struct TokenInBody: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }

    let token: String
    let url: URL

    var requestParametrs: Any {
        return token
    }

    var patch: URL {
        return url
    }

    var header: RequestHeaderParametrs {
        return RequestHeaders.base() + RequestHeaders.deviceUuidHeader()
    }
}

private struct ValidatePhoneNumber: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }

    let token: String
    let otp: String

    var requestParametrs: Any {
        let dict: [String: Any] = [
            LbRequestkeys.referenceToken: token,
            LbRequestkeys.otp: otp
        ]

        return dict
    }

    var patch: URL {
        return RouteRequests.ForgotMyPassword.validatePhoneNumber
    }

    var header: RequestHeaderParametrs {
        return RequestHeaders.base() + RequestHeaders.deviceUuidHeader()
    }
}

private struct ValidateSecurityQuestion: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }

    let referenceToken: String
    let questionId: Int
    let answer: String

    var requestParametrs: Any {
        let dict: [String: Any] = [
            LbRequestkeys.referenceToken: referenceToken,
            LbRequestkeys.securityQuestionId: questionId,
            LbRequestkeys.securityQuestionAnswer: answer
        ]

        return dict
    }

    var patch: URL {
        return RouteRequests.ForgotMyPassword.validateSecurityQuestion
    }

    var header: RequestHeaderParametrs {
        return RequestHeaders.base() + RequestHeaders.deviceUuidHeader()
    }
}

private struct ChangePassword: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }

    let referenceToken: String
    let password: String

    var requestParametrs: Any {
        let dict: [String: Any] = [
            LbRequestkeys.token: referenceToken,
            LbRequestkeys.password: password,
            LbRequestkeys.repeatPassword: password
        ]

        return dict
    }

    var patch: URL {
        return RouteRequests.ForgotMyPassword.change
    }

    var header: RequestHeaderParametrs {
        return RequestHeaders.base() + RequestHeaders.deviceUuidHeader()
    }
}
