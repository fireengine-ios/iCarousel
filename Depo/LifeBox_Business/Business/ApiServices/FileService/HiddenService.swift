//
//  ItemStatusAPIService.swift
//  Depo
//
//  Created by Konstantin Studilin on 10/01/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Alamofire

final class HiddenService {
    
    // MARK: - All
    
    @discardableResult
    func trashedList(folderUUID: String = "ROOT_FOLDER",
                     sortBy: SortType,
                     sortOrder: SortOrder,
                     page: Int,
                     size: Int,
                     folderOnly: Bool,
                     handler: @escaping (ResponseResult<FileListResponse>) -> Void) -> URLSessionTask? {
        debugLog("trashedList")
        
        let folder = folderOnly ? "true" : "false"
        let url = String(format: RouteRequests.baseUrl.absoluteString + RouteRequests.FileSystem.trashedList, folderUUID,
                         sortBy.description, sortOrder.description,
                         page.description, size.description, folder)

        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    // MARK: - Recover
    
    @discardableResult
    func recoverItems(_ items: [WrapData],
                      handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("recoverItems")
        let ids = items.compactMap { $0.uuid }
        return recoverItemsByUuids(ids, handler: handler)
    }
    
    /**
     UUID of file(s) and/or folder(s) to recover them.
     
     - Important:
     NOT for albums
     */
    private func recoverItemsByUuids(_ uuids: [String],
                                     handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("recoverItemsByUuids")
        
        return SessionManager
            .customDefault
            .request(RouteRequests.FileSystem.recover,
                     method: .post,
                     parameters: uuids.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
    //MARK: - Delete
    
    @discardableResult
    func delete(items: [Item], handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("deleteItems")
        let uuids = items.compactMap { $0.uuid }
        return deleteItemsBy(uuids: uuids, handler: handler)
    }
    
    private func deleteItemsBy(uuids: [String], handler: @escaping ResponseVoid) -> URLSessionTask? {
        let path = RouteRequests.baseUrl.absoluteString + RouteRequests.FileSystem.delete
        return SessionManager
        .customDefault
        .request(path,
                 method: .delete,
                 parameters: uuids.asParameters(),
                 encoding: ArrayEncoding())
        .customValidate()
        .responseVoid(handler)
        .task
    }
    
    private func deleteItemsBy(ids: [Int64], path: String, handler: @escaping ResponseVoid) -> URLSessionTask? {
        return SessionManager
        .customDefault
        .request(path,
                 method: .delete,
                 parameters: ids.asParameters(),
                 encoding: ArrayEncoding())
        .customValidate()
        .responseVoid(handler)
        .task
    }
    
    //MARK: - Delete All From Trash Bin
    
    @discardableResult
    func deleteAllFromTrashBin(handler: @escaping ResponseVoid) -> URLSessionTask? {
        return SessionManager
        .customDefault
        .request(RouteRequests.FileSystem.emptyTrash, method: .delete)
        .customValidate()
        .responseVoid(handler)
        .task
    }
}
