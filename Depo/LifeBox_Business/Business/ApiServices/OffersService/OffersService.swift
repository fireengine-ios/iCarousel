//
//  OffersService.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 9/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol OffersService {
    func offersAll(success: SuccessResponse?, fail: @escaping FailResponse)
    func activate(offer: OfferServiceResponse, success: SuccessResponse?, fail: @escaping FailResponse)
    func offersAllApple(success: SuccessResponse?, fail: @escaping FailResponse)
    func validateApplePurchase(with receiptId: String, productId: String?, success: SuccessResponse?, fail: @escaping FailResponse)
    func initOffer(offer: PackageModelResponse, success: SuccessResponse?, fail: @escaping FailResponse)
    func verifyOffer(otp: String, referenceToken: String, success: SuccessResponse?, fail: @escaping FailResponse)
    func getJobExists(success: SuccessResponse?, fail: @escaping FailResponse)
    func submit(promocode: String, success: SuccessResponse?, fail: @escaping FailResponse)
}

class OffersServiceIml: BaseRequestService, OffersService {
    
    func offersAll(success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("OffersServiceIml offersAll")
        
        let param = OfferAllParameters()
        let handler = BaseResponseHandler<OfferAllResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func activate(offer: OfferServiceResponse, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("OffersServiceIml activate")

        let param = OfferAtivateParameters(offer: offer)
        let handler = BaseResponseHandler<OfferActivateServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
    
    func offersAllApple(success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("OffersServiceIml offersAllApple")

        let param = OfferAllAppleParameters()
        let handler = BaseResponseHandler<OfferAllAppleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func validateApplePurchase(with receiptId: String, productId: String?, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("OffersServiceIml validateApplePurchase")

        let param = ValidateApplePurchaseParameters(receiptId: receiptId, productId: productId)
        let handler = BaseResponseHandler<ValidateApplePurchaseResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
    
    func initOffer(offer: PackageModelResponse, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("OffersServiceIml initOffer")

        guard let id = offer.cometOfferId else {
            debugLog("OffersServiceIml initOffer error")

            fail(ErrorResponse.string("Invalid offer"))
            return
        }
        
        let param = InitOfferParameters(offerId: "\(id)")
        let handler = BaseResponseHandler<InitOfferResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
    
    func verifyOffer(otp: String, referenceToken: String, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("OffersServiceIml verifyOffer")

        let param = VerifyOfferParameters(otp: otp, referenceToken: referenceToken)
        let handler = BaseResponseHandler<InitOfferResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
    
    func getJobExists(success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("OffersServiceIml getJobExists")

        let param = JobExistsParameters()
        let handler = BaseResponseHandler<JobExistsResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func submit(promocode: String, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("OffersServiceIml submit")

        let param = SubmitPromocodeParameters(promocode: promocode)
        let handler = BaseResponseHandler<SubmitPromocodeResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
}
