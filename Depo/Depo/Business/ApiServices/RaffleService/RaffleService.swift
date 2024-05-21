//
//  RaffleService.swift
//  Lifebox
//
//  Created by Ozan Salman on 28.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

final class RaffleService: BaseRequestService {
    
    @discardableResult
    func getRaffleStatus(id: Int, handler: @escaping (ResponseResult<RaffleStatusResponse>) -> Void) -> URLSessionTask? {
        debugLog("getRaffleStatus")
        
        let path = String(format: RouteRequests.getRaffleStatus, id)
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
    func getRaffleConditions(id: Int, handler: @escaping (ResponseResult<String>) -> Void) -> URLSessionTask? {
     
        let path = String(format: RouteRequests.getRaffleCondition, id)
        guard let url = URL(string: path, relativeTo: RouteRequests.baseUrl) else {
            assertionFailure()
           return nil
        }
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseString { response in
                switch response.result {
                case .success(let string):
                    handler(.success(string))
                case .failure(let error):
                    handler(.failed(error))
                }
            }
            .task
    }
}

struct RaffleStatusResponse: Codable {
    let totalPointsEarned: Int?
    let details: [Detail]?
    
    struct Detail: Codable {
        let earnType: String?
        let transactionCount, totalPointsEarnedRule, periodEarnedPoints: Int?
        let periodType, packagePeriodType: String?
        let periodEarnLimit, totalEarnLimit: Int?
    }
}

