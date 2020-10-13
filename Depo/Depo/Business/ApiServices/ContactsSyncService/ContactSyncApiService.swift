//
//  ContactSyncApiService.swift
//  Depo
//
//  Created by Andrei Novikau on 6/1/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Alamofire

typealias ContactSyncResponseHandler = (ResponseResult<ContactsResponse>) -> Void

final class ContactSyncApiService {
    enum SortField: String {
        case firstname = "firstname"
        case lastname = "lastname"
    }
    
    enum SortOrder: String {
        case asc = "ASC"
        case desc = "DESC"
    }
    
    @discardableResult
    func getContacts(page: Int, pageSize: Int = 32, sortField: SortField = .firstname, sortOrder: SortOrder = .asc, handler: @escaping ContactSyncResponseHandler) -> URLSessionTask? {
        
        let parameters: [String : Any] = ["currentPage": page,
                                          "maxResult": pageSize,
                                          "sortField": sortField.rawValue,
                                          "sortOrder": sortOrder.rawValue]

        return SessionManager
            .customDefault
            .request(RouteRequests.ContactSync.contact, parameters: parameters)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func searchContacts(query: String, page: Int, pageSize: Int = 16, sortField: SortField = .firstname, sortOrder: SortOrder = .asc, handler: @escaping ContactSyncResponseHandler) -> URLSessionTask? {

        let parameters: [String : Any] = ["query": query,
                                          "currentPage": page,
                                          "maxResult": pageSize,
                                          "sortField": sortField.rawValue,
                                          "sortOrder": sortOrder.rawValue]

        return SessionManager
            .customDefault
            .request(RouteRequests.ContactSync.search, parameters: parameters)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func deleteContacts(ids: [Int], handler: @escaping ResponseVoid) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(RouteRequests.ContactSync.contact,
                     method: .delete,
                     parameters: ids.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
    @discardableResult
    func deleteAllContacts(handler: @escaping ResponseVoid) -> URLSessionTask? {
        let parameters: [String : Any] = ["markDeleted": true, "permanent": false]

        return SessionManager
            .customDefault
            .request(RouteRequests.ContactSync.contact, method: .delete, parameters: parameters, encoding: URLEncoding.queryString)
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
    @discardableResult
    func getBackups(handler: @escaping ResponseHandler<ContactsBackupResponse>) -> URLSessionTask? {
        return SessionManager
            .customDefault
            .request(RouteRequests.ContactSync.backup)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func getContacts(backupId: Int64, page: Int, pageSize: Int = 32, sortField: SortField = .firstname, sortOrder: SortOrder = .asc, handler: @escaping ContactSyncResponseHandler) -> URLSessionTask? {
        guard let url = URL(string: String(format: RouteRequests.ContactSync.backupContacts, backupId)) else {
            assertionFailure()
            return nil
        }
        
        let parameters: [String : Any] = ["currentPage": page,
                                          "maxResult": pageSize,
                                          "sortField": sortField.rawValue,
                                          "sortOrder": sortOrder.rawValue]
        
        return SessionManager
            .customDefault
            .request(url, parameters: parameters)
            .customValidate()
            .responseObject(handler)
            .task
    }
}
