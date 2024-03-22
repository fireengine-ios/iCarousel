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
    func deleteSelectedPhotos(groupId: Int, photoIds: [Int], handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("deleteSelectedPhotos")
        
        let url = RouteRequests.HomeCards.deleteSelectedPhotos(for: groupId)
        
        let parameters: [String: Any] = ["delete": photoIds]
        
        return SessionManager
            .customDefault
            .request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
    @discardableResult
    func keepAllPhotosInGroup(groupId: Int?, photoIds: [Int], handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("keepAllPhotosInGroup")
        
        let url = RouteRequests.HomeCards.deleteSelectedPhotos(for: groupId ?? 0)
        
        let parameters: [String: Any] = ["delete": photoIds]
        
        return SessionManager
            .customDefault
            .request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .customValidate()
            .responseVoid(handler)
            .task
    }
}





