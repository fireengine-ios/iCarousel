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
    func beginResetFlow(with params: ForgotPassword)
    func proceedVerification(with method: IdentityVerificationMethod)
}

final class ResetPasswordService: BaseRequestService, ResetPasswordServiceProtocol {
    weak var delegate: ResetPasswordServiceDelegate?

    private let sessionManager = SessionManager.customDefault
    private var referenceToken: String?

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
        guard let referenceToken = self.referenceToken else {
            return
        }

        switch method {
        case .email:
            callSendEmail(referenceToken: referenceToken) { result in
                switch result {
                case .success:
                    self.delegate?.resetPasswordService(self, verifiedWithMethod: method)
                case let .failure(error):
                    self.delegate?.resetPasswordService(self, receivedError: error)
                }
            }

        case .recoveryEmail:
            callSendRecoveryEmail(referenceToken: referenceToken) { result in
                switch result {
                case .success:
                    self.delegate?.resetPasswordService(self, verifiedWithMethod: method)
                case let .failure(error):
                    self.delegate?.resetPasswordService(self, receivedError: error)
                }
            }

        case let .sms(phoneNumber):
            break

        case let .securityQuestion(questionId):
            break

        case .unknown:
            break
        }
    }

    private func handleFirstResponse(_ response: ResetPasswordResponse) {
        referenceToken = response.referenceToken
        delegate?.resetPasswordService(self, receivedVerificationMethods: response.methods)
    }
}

// MARK: - API Calls
private extension ResetPasswordService {
    typealias ResponseCompletion<R> = (Swift.Result<R, Error>) -> Void

    func callForgotMyPassword(params: ForgotPassword,
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
        let param = SendEmail(referenceToken: referenceToken)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { _ in
            completion(.success(Void()))
        } fail: { error in
            completion(.failure(error))
        }
        executePostRequest(param: param, handler: handler)
    }

    func callSendRecoveryEmail(referenceToken: String, completion: @escaping ResponseCompletion<Void>) {
        let param = SendRecoveryEmail(referenceToken: referenceToken)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse> { _ in
            completion(.success(Void()))
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

private struct SendEmail: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }

    let referenceToken: String

    var requestParametrs: Any {
        return referenceToken
    }

    var patch: URL {
        return RouteRequests.ForgotMyPassword.sendEmail
    }

    var header: RequestHeaderParametrs {
        return RequestHeaders.base() + RequestHeaders.deviceUuidHeader()
    }
}

private struct SendRecoveryEmail: RequestParametrs {
    var timeout: TimeInterval {
        return NumericConstants.defaultTimeout
    }

    let referenceToken: String

    var requestParametrs: Any {
        return referenceToken
    }

    var patch: URL {
        return RouteRequests.ForgotMyPassword.sendRecoveryEmail
    }

    var header: RequestHeaderParametrs {
        return RequestHeaders.base() + RequestHeaders.deviceUuidHeader()
    }
}


