//
//  PrivateShareApiService.swift
//  Depo_LifeTech
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Alamofire

protocol PrivateShareApiService {
    @discardableResult
    func getSuggestions(handler: @escaping ResponseArrayHandler<SuggestedApiContact>) -> URLSessionTask?
    
    @discardableResult
    func getSharedByMe(size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask?
    
    @discardableResult
    func getSharedWithMe(size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseArrayHandler<SharedFileInfo>) -> URLSessionTask?
    
    @discardableResult
    func getFiles(projectId: String, folderUUID: String, size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseHandler<FileSystem>) -> URLSessionTask?
    
    func privateShare(object: PrivateShareObject, handler: @escaping ResponseVoid) -> URLSessionTask?
    
    @discardableResult
    func getSharingInfo(projectId: String, uuid: String, handler: @escaping ResponseHandler<SharedFileInfo>) -> URLSessionTask?
    
    @discardableResult
    func endShare(projectId: String, uuid: String, handler: @escaping ResponseVoid) -> URLSessionTask?
    
    @discardableResult
    func leaveShare(projectId: String, uuid: String, subjectId: String, handler: @escaping ResponseVoid) -> URLSessionTask?
    
    @discardableResult
    func createDownloadUrl(uuids: [String], handler: @escaping ResponseHandler<UrlToDownload>) -> URLSessionTask?
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
    
    @discardableResult
    func getFiles(projectId: String, folderUUID: String, size: Int, page: Int, sortBy: SortType, sortOrder: SortOrder, handler: @escaping ResponseHandler<FileSystem>) -> URLSessionTask? {
        let url = String(format: RouteRequests.FileSystem.Version_2.filesFromFolder, projectId, size, page, sortBy.description, sortOrder.description, folderUUID)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
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
    
    @discardableResult
    func getSharingInfo(projectId: String, uuid: String, handler: @escaping ResponseHandler<SharedFileInfo>) -> URLSessionTask? {
        guard let url = URL(string: String(format: RouteRequests.FileSystem.Version_2.sharingInfo, projectId, uuid)) else {
            handler(.failed(ErrorResponse.string("Incorrect URL")))
            return nil
        }

        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func endShare(projectId: String, uuid: String, handler: @escaping ResponseVoid) -> URLSessionTask? {
        guard let url = URL(string: String(format: RouteRequests.FileSystem.Version_2.shareAcls, projectId, uuid)) else {
            handler(.failed(ErrorResponse.string("Incorrect URL")))
            return nil
        }
        
        return SessionManager
            .customDefault
            .request(url, method: .delete)
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
    @discardableResult
    func leaveShare(projectId: String, uuid: String, subjectId: String, handler: @escaping ResponseVoid) -> URLSessionTask? {
        guard let url = URL(string: String(format: RouteRequests.FileSystem.Version_2.leaveShare, projectId, uuid, subjectId)) else {
            handler(.failed(ErrorResponse.string("Incorrect URL")))
            return nil
        }
        
        return SessionManager
            .customDefault
            .request(url, method: .delete)
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
    @discardableResult
    func createDownloadUrl(uuids: [String], handler: @escaping ResponseHandler<UrlToDownload>) -> URLSessionTask? {
        guard !uuids.isEmpty else {
            handler(.failed(ErrorResponse.string("UUIDs are empty")))
            return nil
        }
        
        let parameters = uuids.asParameters()
        
        return SessionManager
            .customDefault
            .request(RouteRequests.FileSystem.Version_2.createDownloadUrl,
                     method: .post,
                     parameters: parameters,
                     encoding: ArrayEncoding())
            .customValidate()
            .responseObject(handler)
            .task
    }
}
