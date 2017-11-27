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
}

class OffersServiceIml: BaseRequestService, OffersService {
    
    func offersAll(success: SuccessResponse?, fail: @escaping FailResponse) {
        let param = OfferAllParameters()
        let handler = BaseResponseHandler<OfferAllResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func activate(offer: OfferServiceResponse, success: SuccessResponse?, fail: @escaping FailResponse) {
        let param = OfferAtivateParameters(offer: offer)
        let handler = BaseResponseHandler<OfferActivateServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
    
    func offersAllApple(success: SuccessResponse?, fail: @escaping FailResponse) {
        let param = OfferAllAppleParameters()
        let handler = BaseResponseHandler<OfferAllAppleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
    
    func validateApplePurchase(with receiptId: String, productId: String?, success: SuccessResponse?, fail: @escaping FailResponse) {
        let param = ValidateApplePurchaseParameters(receiptId: receiptId, productId: productId)
        let handler = BaseResponseHandler<OfferAllAppleServiceResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
}
