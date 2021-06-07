//
//  InvitationApiService.swift
//  Depo
//
//  Created by Alper Kırdök on 10.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Alamofire

final class InvitationApiService: BaseRequestService {
    @discardableResult
    func getInvitationLink(handler: @escaping ResponseHandler<InvitationLink>) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(RouteRequests.Invitation.link)
            .customValidate()
            .responseObject(handler)
            .task
    }

    @discardableResult
    func getInvitationCampaign(handler: @escaping ResponseHandler<InvitationCampaignResponse>) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(RouteRequests.Invitation.campaign)
            .customValidate()
            .responseObject(handler)
            .task
    }

    @discardableResult
    func getInvitationList(pageNumber: Int, pageSize: Int, handler: @escaping ResponseHandler<InvitationRegisteredResponse>) -> URLSessionTask? {

        let path = String(format: RouteRequests.Invitation.acceptedInvitationList, pageNumber, pageSize)
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

    func getInvitationSubscriptions(success: SuccessResponse?, fail: @escaping FailResponse) {
        let param = InvitationParameters()
        let handler = BaseResponseHandler<ActiveSubscriptionResponse, ObjectRequestResponse>(success: success, fail: fail)
        executeGetRequest(param: param, handler: handler)
    }
}

