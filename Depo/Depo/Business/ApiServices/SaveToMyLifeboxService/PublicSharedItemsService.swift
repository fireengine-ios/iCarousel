//
//  PublicSharedItemsSaveParameters.swift
//  Lifebox
//
//  Created by Burak Donat on 9.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Alamofire

class PublicSharedItemsSaveParameters: BaseRequestParametrs {
    let uuids: [String]
    let publicToken: String
    
    init(uuids: [String], publicToken: String) {
        self.uuids = uuids
        self.publicToken = publicToken
    }
    
    override var requestParametrs: Any {
        return uuids
    }
    
    override var patch: URL {
        let path = String(format: RouteRequests.saveToMyLifeboxSave, publicToken)
        return URL(string: path, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PublicSharedItemsService: BaseRequestService {
    @discardableResult
    func getPublicSharedItemsList(publicToken: String, size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask? {
        let url = String(format: RouteRequests.saveToMyLifeboxList, publicToken, sortBy.description, sortOrder.description, page, size)
        
        return SessionManager
            .sessionWithoutAuth
            .request(url)
            .customValidate()
            .responseArray(handler)
            .task
    }
    
    @discardableResult
    func getPublicSharedItemsInnerFolder(tempListingURL: String, size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask? {
        let url = String(format: RouteRequests.saveToMyLifeboxInnerFolder, tempListingURL, sortBy.description, sortOrder.description, page, size)
        
        return SessionManager
            .sessionWithoutAuth
            .request(url)
            .customValidate()
            .responseArray(handler)
            .task
    }
    
    
    func savePublicSharedItems(publicToken: String, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("PublicShare saveToMyLifeboxSaveRoot")
        
        let param = PublicSharedItemsSaveParameters(uuids: [], publicToken: publicToken)
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
}
