//
//  SaveToMyLifeboxApiService.swift
//  Lifebox
//
//  Created by Burak Donat on 9.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Alamofire

final class SaveToMyLifeboxApiService: BaseRequestService {
    @discardableResult
    func getSaveToMyLifebox(publicToken: String, size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask? {
        let url = String(format: RouteRequests.saveToMyLifeboxList, publicToken, sortBy.description, sortOrder.description, page, size)
        
        return SessionManager
            .sessionWithoutAuth
            .request(url)
            .customValidate()
            .responseArray(handler)
            .task
    }
    
    @discardableResult
    func getSaveToMyLifeboxInnerFolder(tempListingURL: String, size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask? {
        let url = String(format: RouteRequests.saveToMyLifeboxInnerFolder, tempListingURL, sortBy.description, sortOrder.description, page, size)
        
        return SessionManager
            .sessionWithoutAuth
            .request(url)
            .customValidate()
            .responseArray(handler)
            .task
    }
    
    @discardableResult
    func saveToMyLifeboxSaveRoot(publicToken: String, handler: @escaping ResponseVoid) -> URLSessionTask? {
        let url = String(format: RouteRequests.saveToMyLifeboxSave, publicToken)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
}
