//
//  PublicSharedItemsSaveParameters.swift
//  Lifebox
//
//  Created by Burak Donat on 9.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Alamofire
import Foundation

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
        let path = String(format: RouteRequests.publicShareSave, publicToken)
        return URL(string: path, relativeTo: RouteRequests.baseUrl)!
    }
}

final class PublicSharedItemsService: BaseRequestService {
    @discardableResult
    func getPublicSharedItemsList(publicToken: String, size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask? {
        let url = String(format: RouteRequests.publicShareItemList, publicToken, sortBy.description, sortOrder.description, page, size)
        
        return SessionManager
            .sessionWithoutAuth
            .request(url)
            .customValidate()
            .responseArray(handler)
            .task
    }
    
    @discardableResult
    func getPublicSharedItemsInnerFolder(tempListingURL: String, size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask? {
        let url = String(format: RouteRequests.publicShareInnerFolder, tempListingURL, sortBy.description, sortOrder.description, page, size)
        
        return SessionManager
            .sessionWithoutAuth
            .request(url)
            .customValidate()
            .responseArray(handler)
            .task
    }
    
    @discardableResult
    func getPublicSharedItemsCount(publicToken: String, handler: @escaping ResponseHandler<String>) -> URLSessionTask? {
        let url = String(format: RouteRequests.publicSharedItemsCount, publicToken)
        
        return SessionManager
            .sessionWithoutAuth
            .request(url, method: .get)
            .customValidate()
            .responsePlainString(handler)
            .task
    }
    
    @discardableResult
    func createPublicShareDownloadLink(publicToken: String, uuid: [String], handler: @escaping ResponseHandler<String>) -> URLSessionTask? {
        let url = String(format: RouteRequests.publicShareDownloadLink, publicToken)
        let params = uuid.asParameters()
        
        return SessionManager
            .sessionWithoutAuth
            .request(url, method: .post, parameters: params, encoding: ArrayEncoding())
            .customValidate()
            .responsePlainString(handler)
            .task
    }
    
    func savePublicSharedItems(publicToken: String, success: SuccessResponse?, fail: @escaping FailResponse) {
        debugLog("PublicShareItems saveRoot")
        
        let param = PublicSharedItemsSaveParameters(uuids: [], publicToken: publicToken)
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: success, fail: fail)
        executePostRequest(param: param, handler: handler)
    }
}
