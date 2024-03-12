//
//  DrawCampaignService.swift
//  Depo
//
//  Created by Ozan Salman on 24.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

final class DrawCampaignService: BaseRequestService {
    
    @discardableResult
    func getCampaignStatus(campaignId: Int, handler: @escaping (ResponseResult<CampaignStatusResponse>) -> Void) -> URLSessionTask? {
        debugLog("getCampaignStatus")
        
        let path = String(format: RouteRequests.getCampaignStatus, campaignId)
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
    
    @discardableResult
    func getCampaignPolicy(campaignId: Int, handler: @escaping (ResponseResult<CampaignPolicyResponse>) -> Void) -> URLSessionTask? {
        debugLog("getCampaignStatus")
        
        let path = String(format: RouteRequests.getCampaignPolicy, campaignId)
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
    
    @discardableResult
    func setCampaignApply(campaignId: Int, handler: @escaping (ResponseResult<CampaignApplyResponse>) -> Void) -> URLSessionTask? {
        debugLog("setCampaignApply")
        
        let path = String(format: RouteRequests.setCampaignApply, campaignId)
        guard let url = URL(string: path, relativeTo: RouteRequests.baseUrl) else {
            assertionFailure()
           return nil
        }
        
        return SessionManager
            .customDefault
            .request(url, method: .post)
            .customValidate()
            .responseObject(handler)
            .task
    }
}

struct CampaignApplyResponse: Codable {
    let title, message: String
}
