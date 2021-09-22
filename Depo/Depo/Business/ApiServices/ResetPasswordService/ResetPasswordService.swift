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

    func beginResetFlow(with params: ForgotPassword)
    func proceedVerification(with method: IdentityVerificationMethod)
    func sendOTP()
    func verifyOTP(code: String)
}

final class ResetPasswordService: BaseRequestService, ResetPasswordServiceProtocol {
    typealias ResponseCompletion<R> = (Swift.Result<R, Error>) -> Void

    weak var delegate: ResetPasswordServiceDelegate?

    private let sessionManager = SessionManager.customDefault
    private var referenceToken: String?
    private var latestReferenceToken: String?
    private(set) var isInSecondChallenge: Bool = false

    func beginResetFlow(with params: ForgotPassword) {
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
        guard let referenceToken = self.latestReferenceToken else {
            return
        }

        switch method {
        case .email:
            proceedWithEmail(referenceToken: referenceToken, method: method)

        case .recoveryEmail:
            proceedWithRecoveryEmail(referenceToken: referenceToken, method: method)

        case .sms:
            delegate?.resetPasswordService(self, readyToProceedWithMethod: method)

        case let .securityQuestion(questionId):
            break

        case .unknown:
            break
        }
    }

    func sendOTP() {
        guard let referenceToken = self.latestReferenceToken else { return }
        callSendSMS(referenceToken: referenceToken) { result in
            switch result {
            case let .success(response):
                self.latestReferenceToken = response.referenceToken
                self.delegate?.resetPasswordService(self, receivedOTPResponse: response)
            case let .failure(error):
                self.delegate?.resetPasswordService(self, receivedError: error)
            }
        }
    }

    func verifyOTP(code: String) {
        guard let referenceToken = self.latestReferenceToken else { return }
        callValidatePhoneNumber(referenceToken: referenceToken, otp: code) { result in
            switch result {
            case let .success(response):
                self.isInSecondChallenge = true
                self.latestReferenceToken = response.referenceToken
                self.checkStatusAfterPhoneVerification(referenceToken: response.referenceToken ?? referenceToken)

            case let .failure(error):
                self.delegate?.resetPasswordService(self, receivedError: error)
            }
        }
    }

    private func handleFirstResponse(_ response: ResetPasswordResponse) {
        referenceToken = response.referenceToken
        latestReferenceToken = response.referenceToken
        delegate?.resetPasswordService(self, resetBeganWithMethods: response.methods)
    }

    private func proceedWithEmail(referenceToken: String, method: IdentityVerificationMethod) {
        let completion: ResponseCompletion<Void> = { result in
            switch result {
            case .success:
                self.delegate?.resetPasswordService(self, readyToProceedWithMethod: method)
            case let .failure(error):
                self.delegate?.resetPasswordService(self, receivedError: error)
            }
        }

        if isInSecondChallenge {
            callContinueWithEmail(referenceToken: referenceToken, completion: completion)
        } else {
            callSendEmail(referenceToken: referenceToken, completion: completion)
        }
    }

    private func proceedWithRecoveryEmail(referenceToken: String, method: IdentityVerificationMethod) {
        let completion: ResponseCompletion<Void> = { result in
            switch result {
            case .success:
                self.delegate?.resetPasswordService(self, readyToProceedWithMethod: method)
            case let .failure(error):
                self.delegate?.resetPasswordService(self, receivedError: error)
            }
        }

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
                self.latestReferenceToken = response.referenceToken
                self.delegate?.resetPasswordService(self, phoneVerified: response.methods)
            case let .failure(error):
                self.delegate?.resetPasswordService(self, receivedError: error)
            }
        }
    }
}

// MARK: - API Calls
private extension ResetPasswordService {
    func callForgotMyPassword(params: ForgotPassword,
                              completion: @escaping ResponseCompletion<ResetPasswordResponse>) {
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { legacyResponse in
            do {
                let response = try legacyResponse.decodedResponse(ResetPasswordResponse.self)
                print("referenceToken111", response.referenceToken)
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
                print("referenceToken111", response.referenceToken)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }

    func callValidatePhoneNumber(referenceToken: String, otp: String, completion: @escaping ResponseCompletion<ResetPasswordResponse>) {
        let param = ValidatePhoneNumber(token: referenceToken, otp: otp)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { legacyResponse in
            do {
                let response = try legacyResponse.decodedResponse(ResetPasswordResponse.self)
                print("referenceToken111", response.referenceToken)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }

    func callCheckStatus(referenceToken: String, completion: @escaping ResponseCompletion<ResetPasswordResponse>) {
        let param = TokenInBody(token: referenceToken, url: RouteRequests.ForgotMyPassword.checkStatus)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { legacyResponse in
            do {
                let response = try legacyResponse.decodedResponse(APIResponse<ResetPasswordResponse>.self)
                print("referenceToken111", response.referenceToken)
                completion(.success(response.value))
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
}

// MARK: - Endpoint Param Definitions

struct ForgotPassword: RequestParametrs {
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
