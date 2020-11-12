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
    
    @discardableResult
    func getSharedByMe(size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask?
    
    @discardableResult
    func getSharedWithMe(size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask?
    
    func privateShare(object: PrivateShareObject, handler: @escaping ResponseVoid) -> URLSessionTask?
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
    func getSharedByMe(size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask? {
        let url = String(format: RouteRequests.PrivateShare.Shared.byMe, size, page, sortBy.description, sortOrder.description)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseArray(handler)
            .task
    }
    
    @discardableResult
    func getSharedWithMe(size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask? {
        let url = String(format: RouteRequests.PrivateShare.Shared.withMe, size, page, sortBy.description, sortOrder.description)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseArray(handler)
            .task
    }
    
    func privateShare(object: PrivateShareObject, handler: @escaping ResponseVoid) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(RouteRequests.PrivateShare.share, method: .post, parameters: object.parameters, encoding: JSONEncoding.default)
            .customValidate()
            .responseVoid(handler)
            .task
    }
}
