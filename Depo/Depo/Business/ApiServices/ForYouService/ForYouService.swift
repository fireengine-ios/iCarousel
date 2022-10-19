//
//  ForYouService.swift
//  Depo
//
//  Created by Burak Donat on 10.10.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import Alamofire

final class ForYouService: BaseRequestService {
    @discardableResult
    func forYouStories(handler: @escaping (ResponseResult<FileListResponse>) -> Void) -> URLSessionTask? {
        debugLog("forYouStories")
        
        return SessionManager
            .customDefault
            .request(RouteRequests.forYouStories)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func forYouAnimations(handler: @escaping (ResponseResult<FileListResponse>) -> Void) -> URLSessionTask? {
        debugLog("forYouAnimations")
        
        return SessionManager
            .customDefault
            .request(RouteRequests.forYouAnimations)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func forYouCollages(handler: @escaping (ResponseResult<FileListResponse>) -> Void) -> URLSessionTask? {
        debugLog("forYouCollages")
        
        return SessionManager
            .customDefault
            .request(RouteRequests.forYouCollages)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func forYouThrowbacks(handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        debugLog("forYouThrowback")
        
        return SessionManager
            .customDefault
            .request(RouteRequests.forYouThrowback)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func forYouCards(for view: ForYouViewEnum, handler: @escaping (ResponseResult<[HomeCardResponse]>) -> Void) -> URLSessionTask? {
        debugLog("forYouCards: \(view.title)")
        
        var url = RouteRequests.baseUrl
        
        switch view {
        case .animationCards:
            url = RouteRequests.forYouAnimationCards
        case .collageCards:
            url = RouteRequests.forYouCollageCards
        case .albumCards:
            url = RouteRequests.forYouAlbumCards
        default:
            return nil
        }
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let array = HomeCardResponse.array(from: data)
                    for (i, object) in array.enumerated() {
                        object.order = i + 1
                    }
                    handler(.success(array))
                case .failure(let error):
                    let backendError = ResponseParser.getBackendError(data: response.data,
                                                                      response: response.response)
                    handler(.failed(backendError ?? error))
                }
            }
            .task
    }
}
