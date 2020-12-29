//
//  CampaignService.swift
//  Depo
//
//  Created by Andrei Novikau on 10/18/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Alamofire
import SwiftyJSON

protocol CampaignService: class {
    func getPhotopickDetails(handler: @escaping (ErrorResult<CampaignCardResponse, CampaignPhotopickError>) -> Void)
}
    
final class CampaignServiceImpl: BaseRequestService, CampaignService {

    private enum Keys {
        static let serverValue = "value"
    }
    
    private let sessionManager: SessionManager
    
    required init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
    
    func getPhotopickDetails(handler: @escaping (ErrorResult<CampaignCardResponse, CampaignPhotopickError>) -> Void) {
        sessionManager
        .request(RouteRequests.campaignPhotopick)
        .customValidate()
        .responseData { response in
            switch response.result {
            case .success(let data):
                let json = JSON(data: data)[Keys.serverValue]
                guard let details = CampaignCardResponse(json: json) else {
                    handler(.failure(.empty))
                    return
                }
                
                handler(.success(details))
            case .failure(let error):
                let backendError = ResponseParser.getBackendError(data: response.data,
                                                                  response: response.response)
                handler(.failure(.error(backendError ?? error)))
            }
        }
    }
}
