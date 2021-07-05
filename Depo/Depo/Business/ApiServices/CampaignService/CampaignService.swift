//
//  CampaignService.swift
//  Depo
//
//  Created by Andrei Novikau on 10/18/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Alamofire
import SwiftyJSON

protocol CampaignService: AnyObject {
    typealias ResponseHandler = (Swift.Result<PhotopickCampaign, CampaignServiceError>) -> Void

    @discardableResult
    func getPhotopickDetails(completion: @escaping ResponseHandler) -> URLSessionTask?
}

enum CampaignServiceError: Error {
    case empty
    case other(error: Error)
}

final class CampaignServiceImpl: CampaignService {

    private let sessionManager: SessionManager
    
    required init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }

    @discardableResult
    func getPhotopickDetails(completion: @escaping CampaignService.ResponseHandler) -> URLSessionTask? {
        sessionManager
            .request(RouteRequests.campaignPhotopick)
            .customValidate()
            .responseObject { (result: ResponseResult<PhotopickCampaignResponse>) in
                do {
                    let response = try result.asSwiftResult().get()
                    completion(.success(response.value))
                } catch is DecodingError {
                    completion(.failure(.empty))
                } catch {
                    completion(.failure(.other(error: error)))
                }
            }
            .task
    }

    func getPhotopickDetails(from data: Data) throws -> PhotopickCampaign {
        do {
            let decoder = JSONDecoder.withMillisecondsDate()
            return try decoder.decode(PhotopickCampaign.self, from: data)
        } catch {
            throw CampaignServiceError.empty
        }
    }
}
