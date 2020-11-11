//
//  PrivateShareApiService.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Alamofire

protocol PrivateShareApiService {
    func getSuggestions(handler: @escaping ResponseArrayHandler<SuggestedApiContact>) -> URLSessionTask?
}

final class PrivateShareApiServiceImpl: PrivateShareApiService {
    
    @discardableResult
    func getSuggestions(handler: @escaping ResponseArrayHandler<SuggestedApiContact>) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(RouteRequests.PrivateShare.suggestions)
            .customValidate()
            .responseArray(handler)
            .task
    }
    
    @discardableResult
    func privateShare(object: PrivateShareObject, handler: @escaping ResponseVoid) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(RouteRequests.PrivateShare.share, method: .post, parameters: object.parameters, encoding: JSONEncoding.default)
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
}
