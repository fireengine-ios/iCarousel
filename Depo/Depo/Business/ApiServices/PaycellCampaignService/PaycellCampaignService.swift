//
//  PaycellCampaignService.swift
//  Depo
//
//  Created by Burak Donat on 7.08.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

final class PaycellCampaignService: BaseRequestService {
    @discardableResult
    func getPaycellLink(handler: @escaping ResponseHandler<PaycellLinkResponse>) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(RouteRequests.paycellLink)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func getPaycellDetail(handler: @escaping ResponseHandler<PaycellDetailResponse>) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(RouteRequests.paycellDetail)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func paycellConsent(handler: @escaping ResponseVoid) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(RouteRequests.paycellConsent, method: .post)
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
    @discardableResult
    func paycellGain(handler: @escaping ResponseHandler<PaycellGainResponse>) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(RouteRequests.paycellGain)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func paycellAcceptedList(pageNumber: Int, pageSize: Int, handler: @escaping ResponseHandler<InvitationRegisteredResponse>) -> URLSessionTask? {

        let path = String(format: RouteRequests.paycellAcceptedFriends, pageNumber, pageSize)
        guard let url = URL(string: path, relativeTo: RouteRequests.baseUrl) else {
            assertionFailure()
           return nil
        }
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
}
