//
//  BestSceneService.swift
//  Lifebox
//
//  Created by Rustam Manafov on 10.03.24.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

final class BestSceneService: BaseRequestService {
    
    @discardableResult
    func deleteSelectedPhotos(groupId: Int, photoIds: [String], handler: @escaping (ResponseResult<DeletePhotosResponse>) -> Void) -> URLSessionTask? {
        debugLog("deleteSelectedPhotos")
        
        let url = RouteRequests.HomeCards.deleteSelectedPhotos(for: groupId)
        
        let parameters: Parameters = ["delete": photoIds]
        
        print("⚠️", parameters)
        
        return SessionManager
            .customDefault
            .request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func keepAllPhotosInGroup(groupId: Int, photoIds: [String], handler: @escaping (ResponseResult<KeepAllPhotosResponse>) -> Void) -> URLSessionTask? {
        debugLog("keepAllPhotosInGroup")
        
        let url = RouteRequests.HomeCards.deleteSelectedPhotos(for: groupId)
        
        let parameters: Parameters = ["delete": photoIds]
        print("⚠️", parameters)

        
        return SessionManager
            .customDefault
            .request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .customValidate()
            .responseObject(handler)
            .task
    }
}





