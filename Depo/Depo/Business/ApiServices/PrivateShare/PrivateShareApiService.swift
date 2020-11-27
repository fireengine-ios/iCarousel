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
    
    @discardableResult
    func privateShare(object: PrivateShareObject, handler: @escaping ResponseVoid) -> URLSessionTask?
    
    @discardableResult
    func getSharingInfo(projectId: String, uuid: String, handler: @escaping ResponseHandler<SharedFileInfo>) -> URLSessionTask?
    
    @discardableResult
    func endShare(projectId: String, uuid: String, handler: @escaping ResponseVoid) -> URLSessionTask?
    
    @discardableResult
    func getAccessList(projectId: String, uuid: String, subjectType: PrivateShareSubjectType, subjectId: String, handler: @escaping ResponseArrayHandler<PrivateShareAccessListInfo>) -> URLSessionTask?
    
    @discardableResult
    func updateAclRole(newRole: PrivateShareUserRole, projectId: String, uuid: String, aclId: Int64, handler: @escaping ResponseVoid) -> URLSessionTask?
    
    @discardableResult
    func deleteAclUser(projectId: String, uuid: String, aclId: Int64, handler: @escaping ResponseVoid) -> URLSessionTask?

    @discardableResult
    func leaveShare(projectId: String, uuid: String, subjectId: String, handler: @escaping ResponseVoid) -> URLSessionTask?
    
    @discardableResult
    func createDownloadUrl(projectId: String, uuid: String, handler: @escaping ResponseHandler<WrappedUrl>) -> URLSessionTask?
    
    @discardableResult
    func renameItem(projectId: String, uuid: String, name: String, handler: @escaping ResponseVoid) -> URLSessionTask?

    @discardableResult
    func moveToTrash(projectId: String, uuid: String, handler: @escaping ResponseVoid) -> URLSessionTask?
    
    @discardableResult
    func createFolder(projectId: String, parentFolderUuid: String, requestItem: CreateFolderResquestItem, handler: @escaping ResponseHandler<SharedFileInfo>) -> URLSessionTask?
    
    @discardableResult
    func getUrlToUpload(projectId: String, parentFolderUuid: String, requestItem: UploadFileRequestItem, handler: @escaping ResponseHandler<WrappedUrl>) -> URLSessionTask?
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
    
    @discardableResult
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
    func getAccessList(projectId: String, uuid: String, subjectType: PrivateShareSubjectType = .user, subjectId: String, handler: @escaping ResponseArrayHandler<PrivateShareAccessListInfo>) -> URLSessionTask? {
        guard let url = URL(string: String(format: RouteRequests.FileSystem.Version_2.shareAcls, projectId, uuid)) else {
            handler(.failed(ErrorResponse.string("Incorrect URL")))
            return nil
        }
        
        let parameters = ["subjectType": subjectType.rawValue,
                          "subjectId": subjectId]
        
        return SessionManager
            .customDefault
            .request(url,
                     method: .get,
                     parameters: parameters,
                     encoding: URLEncoding.default)
            .customValidate()
            .responseArray(handler)
            .task
    }
    
    @discardableResult
    func updateAclRole(newRole: PrivateShareUserRole, projectId: String, uuid: String, aclId: Int64, handler: @escaping ResponseVoid) -> URLSessionTask? {
        guard let url = URL(string: String(format: RouteRequests.FileSystem.Version_2.shareAcl, projectId, uuid, aclId)) else {
            handler(.failed(ErrorResponse.string("Incorrect URL")))
            return nil
        }
        
        let parameters = ["role": newRole.rawValue]
        
        return SessionManager
            .customDefault
            .request(url,
                     method: .put,
                     parameters: parameters,
                     encoding: JSONEncoding.default)
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
    @discardableResult
    func deleteAclUser(projectId: String, uuid: String, aclId: Int64, handler: @escaping ResponseVoid) -> URLSessionTask? {
        guard let url = URL(string: String(format: RouteRequests.FileSystem.Version_2.shareAcl, projectId, uuid, aclId)) else {
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
    func createDownloadUrl(projectId: String, uuid: String, handler: @escaping ResponseHandler<WrappedUrl>) -> URLSessionTask? {
        
        let parameters = [["projectId" : projectId, "uuid" : uuid]].asParameters()
        
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
    
    @discardableResult
    func renameItem(projectId: String, uuid: String, name: String, handler: @escaping ResponseVoid) -> URLSessionTask? {
        guard let url = URL(string: String(format: RouteRequests.FileSystem.Version_2.rename, projectId, uuid)) else {
            handler(.failed(ErrorResponse.string("Incorrect URL")))
            return nil
        }
        
        let parameters = ["name": name]
        
        return SessionManager
            .customDefault
            .request(url,
                     method: .post,
                     parameters: parameters,
                     encoding: JSONEncoding.default)
            .customValidate()
            .responseVoid(handler)
            .task
    }
        
    @discardableResult
    func moveToTrash(projectId: String, uuid: String, handler: @escaping ResponseVoid) -> URLSessionTask? {
        
        let parameters = [["projectId" : projectId, "uuid" : uuid]].asParameters()
        
        return SessionManager
            .customDefault
            .request(RouteRequests.FileSystem.Version_2.trash,
                     method: .post,
                     parameters: parameters,
                     encoding: ArrayEncoding())
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
    @discardableResult
    func createFolder(projectId: String, parentFolderUuid: String, requestItem: CreateFolderResquestItem, handler: @escaping ResponseHandler<SharedFileInfo>) -> URLSessionTask? {
        guard let url = URL(string: String(format: RouteRequests.FileSystem.Version_2.baseV2UrlString, projectId)) else {
            handler(.failed(ErrorResponse.string("Incorrect URL")))
            return nil
        }
        
        let parameters = ["file": requestItem.parameters] + ["parentFolderUuid": parentFolderUuid]
        
        return SessionManager
            .customDefault
            .request(url, method: .post,
                     parameters: parameters,
                     encoding: JSONEncoding.prettyPrinted)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func getUrlToUpload(projectId: String, parentFolderUuid: String, requestItem: UploadFileRequestItem, handler: @escaping ResponseHandler<WrappedUrl>) -> URLSessionTask? {
        guard let url = URL(string: String(format: RouteRequests.FileSystem.Version_2.baseV2UrlString, projectId)) else {
            handler(.failed(ErrorResponse.string("Incorrect URL")))
            return nil
        }
        
        let parameters = ["file": requestItem.parameters] + ["parentFolderUuid": parentFolderUuid]
        
        return SessionManager
            .customDefault
            .request(url, method: .post,
                     parameters: parameters,
                     encoding: JSONEncoding.prettyPrinted)
            .customValidate()
            .responseObject(handler)
            .task
    }
}
