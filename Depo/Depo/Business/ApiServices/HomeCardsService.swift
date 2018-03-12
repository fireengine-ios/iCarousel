//
//  HomeCardsService.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 1/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

protocol HomeCardsService {
    func all(handler: @escaping (ResponseResult<[HomeCardResponse]>) -> Void)
    func save(with id: Int, handler: @escaping ResponseVoid)
    func delete(with id: Int, handler: @escaping ResponseVoid)
}

final class HomeCardsServiceImp {
    let sessionManager: SessionManager
    
    init(sessionManager: SessionManager = SessionManager.default) {
        self.sessionManager = sessionManager
    }
}

extension HomeCardsServiceImp: HomeCardsService {
    func all(handler: @escaping (ResponseResult<[HomeCardResponse]>) -> Void) {
        sessionManager
            .request(RouteRequests.HomeCards.all)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let array = HomeCardResponse.array(from: data)
                    for (i, object) in array.enumerated() {
                        object.order = i + 1
                    }
                    handler(ResponseResult.success(array))
                case .failure(let error):
                    let backendError = ResponseParser.getBackendError(data: response.data,
                                                                      response: response.response)
                    handler(ResponseResult.failed(backendError ?? error))
                }
            }
    }
    
    func save(with id: Int, handler: @escaping ResponseVoid) {
        let url = RouteRequests.HomeCards.card(with: id)
        sessionManager
            .request(url, method: .put)
            .customValidate()
            .responseVoid(handler)
    }
    
    func delete(with id: Int, handler: @escaping ResponseVoid) {
        let url = RouteRequests.HomeCards.card(with: id)
        sessionManager
            .request(url, method: .delete)
            .customValidate()
            .responseVoid(handler)
    }
}
