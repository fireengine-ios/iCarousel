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
    func trashedList(folderUUID: String = "",
                     sortBy: SortType,
                     sortOrder: SortOrder,
                     page: Int,
                     size: Int,
                     handler: @escaping (ResponseResult<TrashBinRequestResponse>) -> Void) -> URLSessionTask? {
        debugLog("trashedList")

        guard let url = URL(string: String(format: RouteRequests.FileSystem.Version_3.trashedBinList, folderUUID,
                                           sortBy.description, sortOrder.description,
                                           page.description, size.description)) else {
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
    
    // MARK: - Recover
    @discardableResult
    func recoverItems(_ items: [WrapData],
                      handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("recoverItems")

        guard let url = URL(string: RouteRequests.FileSystem.Version_3.recoverFromTrashBin) else {
            handler(.failed(ErrorResponse.string("Incorrect URL")))
            return nil
        }

        let parameters = items.compactMap {["accountUuid" : $0.accountUuid, "uuid" : $0.uuid]}.asParameters()
        
        return SessionManager
            .customDefault
            .request(url,
                     method: .post,
                     parameters: parameters,
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

    @discardableResult
    func deletePermanently(items: [Item], handler: @escaping ResponseVoid) -> URLSessionTask? {

        debugLog("deleteItems")

        guard let url = URL(string: RouteRequests.FileSystem.Version_3.deletePermanently) else {
            handler(.failed(ErrorResponse.string("Incorrect URL")))
            return nil
        }

        let parameters = items.compactMap {["accountUuid" : $0.accountUuid, "uuid" : $0.uuid]}.asParameters()

        return SessionManager
        .customDefault
        .request(url,
                 method: .post,
                 parameters: parameters,
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
