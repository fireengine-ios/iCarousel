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
}
