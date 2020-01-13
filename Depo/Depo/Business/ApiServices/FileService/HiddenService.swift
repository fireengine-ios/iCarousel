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
    func hiddenList(sortBy: SortType,
                    sortOrder: SortOrder,
                    page: Int,
                    size: Int,
                    handler: @escaping (ResponseResult<FileListResponse>) -> Void) -> URLSessionTask? {
        debugLog("hiddenList")
        
        let url = String(format: RouteRequests.FileSystem.hiddenList,
                         sortBy.description, sortOrder.description,
                         page.description, size.description)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
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
    
    @discardableResult
    func hiddenAlbums(sortBy: SortType,
                      sortOrder: SortOrder,
                      page: Int,
                      size: Int,
                      handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        debugLog("hiddenAlbums")
        
        return albumsWithStatus(.hidden, sortBy: sortBy, sortOrder: sortOrder, page: page, size: size, handler: handler)
    }
    
    @discardableResult
    func trashedAlbums(sortBy: SortType,
                       sortOrder: SortOrder,
                       page: Int,
                       size: Int,
                       handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        debugLog("trashedAlbums")
        
        return albumsWithStatus(.trashed, sortBy: sortBy, sortOrder: sortOrder, page: page, size: size, handler: handler)
    }
    
    private func albumsWithStatus(_ status: ItemStatus, sortBy: SortType,
                        sortOrder: SortOrder,
                        page: Int,
                        size: Int,
                        handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        let url = String(format: RouteRequests.albumListWithStatus,
                         SearchContentType.album.description,
                         page.description, size.description,
                         sortBy.description, sortOrder.description, status.rawValue)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    // MARK: - SmartAlbum Detail
    
    @discardableResult
    func hiddenPlacesAlbumDetail(id: Int,
                                 handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        debugLog("hiddenPlacesAlbumDetail")
        
        return placesAlbumDetailWithStatus(status: .hidden, id: id, handler: handler)
    }
    
    @discardableResult
    func trashedPlacesAlbumDetail(id: Int,
                                  handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        debugLog("trashedPlacesAlbumDetail")
        
        return placesAlbumDetailWithStatus(status: .trashed, id: id, handler: handler)
    }
    
    private func placesAlbumDetailWithStatus(status: ItemStatus, id: Int,
                                         handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        let url = String(format: RouteRequests.placesAlbumWithStatus, id, status.rawValue)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func hiddenPeopleAlbumDetail(id: Int,
                                 handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        debugLog("hiddenPeopleAlbumDetail")
        
        return peopleAlbumDetailWithStatus(status: .hidden, id: id, handler: handler)
    }
    
    
    @discardableResult
    func trashedPeopleAlbumDetail(id: Int,
                                  handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        debugLog("trashedPeopleAlbumDetail")
        
        return peopleAlbumDetailWithStatus(status: .trashed, id: id, handler: handler)
    }
    
    private func peopleAlbumDetailWithStatus(status: ItemStatus, id: Int, handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        let url = String(format: RouteRequests.peopleAlbumWithStatus, id, status.rawValue)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    
    @discardableResult
    func hiddenThingsAlbumDetail(id: Int,
                                 handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        debugLog("hiddenThingsAlbumDetail")
        
        return thingsAlbumDetailWithStatus(status: .hidden, id: id, handler: handler)
    }
    
    @discardableResult
    func trashedThingsAlbumDetail(id: Int,
                                 handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        debugLog("trashedThingsAlbumDetail")
        
        return thingsAlbumDetailWithStatus(status: .trashed, id: id, handler: handler)
    }
    
    private func thingsAlbumDetailWithStatus(status: ItemStatus, id: Int,
                                          handler: @escaping (ResponseResult<AlbumResponse>) -> Void) -> URLSessionTask? {
        let url = String(format: RouteRequests.thingsAlbumWithStatus, id, status.rawValue)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    // MARK: - SmartAlbum All
    
    @discardableResult
    func hiddenPlacesPage(page: Int,
                          size: Int,
                          handler: @escaping (ResponseResult<PlacesPageResponse>) -> Void) -> URLSessionTask? {
        debugLog("hiddenPlacesPage")
        
        return placesPageWithStatus(status: .hidden, page: page, size: size, handler: handler)
    }
    
    @discardableResult
    func trashedPlacesPage(page: Int,
                           size: Int,
                           handler: @escaping (ResponseResult<PlacesPageResponse>) -> Void) -> URLSessionTask? {
        debugLog("trashedPlacesPage")
        
        return placesPageWithStatus(status: .trashed, page: page, size: size, handler: handler)
    }
    
    private func placesPageWithStatus(status: ItemStatus, page: Int,
                              size: Int,
                              handler: @escaping (ResponseResult<PlacesPageResponse>) -> Void) -> URLSessionTask? {
        let url = String(format: RouteRequests.placesPageWithStatus, size, page, status.rawValue)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func hiddenPeoplePage(page: Int,
                          size: Int,
                          handler: @escaping (ResponseResult<PeoplePageResponse>) -> Void) -> URLSessionTask? {
        debugLog("hiddenPeoplePage")
        
        return hiddenPeoplePageWithStatus(status: .hidden, page: page, size: size, handler: handler)
    }
    
    @discardableResult
    func trashedPeoplePage(page: Int,
                           size: Int,
                           handler: @escaping (ResponseResult<PeoplePageResponse>) -> Void) -> URLSessionTask? {
        debugLog("trashedPeoplePage")
        
        return hiddenPeoplePageWithStatus(status: .trashed, page: page, size: size, handler: handler)
    }
    
    private func hiddenPeoplePageWithStatus(status: ItemStatus, page: Int,
                                            size: Int,
                                            handler: @escaping (ResponseResult<PeoplePageResponse>) -> Void) -> URLSessionTask? {
        let url = String(format: RouteRequests.peoplePageWithStatus, size, page, status.rawValue)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    @discardableResult
    func hiddenThingsPage(page: Int,
                          size: Int,
                          handler: @escaping (ResponseResult<ThingsPageResponse>) -> Void) -> URLSessionTask? {
        debugLog("hiddenThingsPage")
        
        return thingsPageWithStatus(status: .hidden, page: page, size: size, handler: handler)
    }
    
    @discardableResult
    func trashedThingsPage(page: Int,
                           size: Int,
                           handler: @escaping (ResponseResult<ThingsPageResponse>) -> Void) -> URLSessionTask? {
        debugLog("trashedThingsPage")
        
        return thingsPageWithStatus(status: .trashed, page: page, size: size, handler: handler)
    }
    
    private func thingsPageWithStatus(status: ItemStatus, page: Int,
                                      size: Int,
                                      handler: @escaping (ResponseResult<ThingsPageResponse>) -> Void) -> URLSessionTask? {
        let url = String(format: RouteRequests.thingsPageWithStatus, size, page, status.rawValue)
        
        return SessionManager
            .customDefault
            .request(url)
            .customValidate()
            .responseObject(handler)
            .task
    }
    
    // MARK: - Hide
    
    @discardableResult
    func hideItems(_ items: [WrapData],
                   handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("hideItems")
        let ids = items.compactMap { $0.uuid }
        return hideItemsByUuids(ids, handler: handler)
    }
    
    private func hideItemsByUuids(_ uuids: [String],
                                  handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("hideItemsByUuids")
        
        return SessionManager
            .customDefault
            .request(RouteRequests.FileSystem.hide,
                     method: .delete,
                     parameters: uuids.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
    @discardableResult
    func hideAlbums(_ albums: [AlbumServiceResponse],
                    handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("hideAlbums")
        let ids = albums.compactMap { $0.uuid }
        return hideItemsByUuids(ids, handler: handler)
    }
    
    @discardableResult
    func hideAlbums(_ albums: [AlbumItem],
                    handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("hideAlbums")
        let ids = albums.compactMap { $0.uuid }
        return hideAlbumByUuids(ids, handler: handler)
    }
    
    private func hideAlbumByUuids(_ uuids: [String],
                                  handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("hideAlbumByUuids")
        
        return SessionManager
            .customDefault
            .request(RouteRequests.albumHide,
                     method: .delete,
                     parameters: uuids.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseVoid(handler)
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
    
    @discardableResult
    func recoverAlbums(_ albums: [AlbumServiceResponse],
                       handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("recoverAlbums AlbumServiceResponse")
        let ids = albums.compactMap { $0.uuid }
        return recoverAlbumsByUuids(ids, handler: handler)
    }
    
    @discardableResult
    func recoverAlbums(_ albums: [AlbumItem],
                       handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("recoverAlbums AlbumItem")
        let ids = albums.compactMap { $0.uuid }
        return recoverAlbumsByUuids(ids, handler: handler)
    }
    
    private func recoverAlbumsByUuids(_ uuids: [String],
                                      handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("recoverAlbumsByUuids")
        
        return SessionManager
            .customDefault
            .request(RouteRequests.albumRecover,
                     method: .post,
                     parameters: uuids.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseVoid(handler)
            .task
    }
 
    //MARK: - Smart Albums Recovery
    
    private func recoverSmartAlbum(items: [Item], path: String, handler: @escaping ResponseVoid) -> URLSessionTask? {
        let ids = items.compactMap { $0.id }
        
        return SessionManager
            .customDefault
            .request(path,
                     method: .post,
                     parameters: ids.asParameters(),
                     encoding: ArrayEncoding())
            .customValidate()
            .responseVoid(handler)
            .task
    }
    
    //MARK: People
    @discardableResult
    func unhidePeople(items: [PeopleItem],
                      handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("unhidePeopleItems")
        return recoverPeople(items: items, handler: handler)
    }
    
    @discardableResult
    func putBackPeople(items: [PeopleItem],
                       handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("putBackPeopleItems")
        return recoverPeople(items: items, handler: handler)
    }
    
    private func recoverPeople(items: [PeopleItem],
                        handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("recoverPeopleItems")
        let recoveringItems = items.filter { $0.id != nil }
        return recoverSmartAlbum(items: recoveringItems, path: RouteRequests.peopleRecovery, handler: handler)
    }
    
    
    //MARK: Places
    
    @discardableResult
    func unhidePlaces(items: [PlacesItem],
                      handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("unhidePlacesItems")
        return recoverPlaces(items: items, handler: handler)
    }
    
    @discardableResult
    func putBackPlaces(items: [PlacesItem],
                       handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("putBackPlacesItems")
        return recoverPlaces(items: items, handler: handler)
    }
    
    private func recoverPlaces(items: [PlacesItem],
                               handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("recoverPlacesItems")
        let recoveringItems = items.filter { $0.id != nil }
        return recoverSmartAlbum(items: recoveringItems, path: RouteRequests.placesRecovery, handler: handler)
    }
    
    
    //MARK: Things
    
    @discardableResult
    func unhideThings(items: [ThingsItem],
                        handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("unhideThingsItems")
        return recoverThings(items: items, handler: handler)
    }
    
    @discardableResult
    func putBackThings(items: [ThingsItem],
                        handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("putBackThingsItems")
        return recoverThings(items: items, handler: handler)
    }
    
    private func recoverThings(items: [ThingsItem],
                               handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("recoverThingsItems")
        let recoveringItems = items.filter { $0.id != nil }
        return recoverSmartAlbum(items: recoveringItems, path: RouteRequests.thingsRecovery, handler: handler)
    }

    
    //MARK: - Smart Albums Trash
    
    @discardableResult
    func moveToTrashPeople(items: [PeopleItem],
                           handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("moveToTrashPeopleItems")
        let trashingItems = items.filter { $0.id != nil }
        return moveToTrashSmartAlbum(items: trashingItems, path: RouteRequests.peopleTrash, handler: handler)
    }
    
    @discardableResult
    func moveToTrashPlaces(items: [PlacesItem],
                           handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("moveToTrashPlacesItems")
        let trashingItems = items.filter { $0.id != nil }
        return moveToTrashSmartAlbum(items: trashingItems, path: RouteRequests.placesTrash, handler: handler)
    }
    
    @discardableResult
    func moveToTrashThings(items: [ThingsItem],
                           handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("moveToTrashThingsItems")
        let trashingItems = items.filter { $0.id != nil }
        return moveToTrashSmartAlbum(items: trashingItems, path: RouteRequests.thingsTrash, handler: handler)
    }
    
    private func moveToTrashSmartAlbum(items: [Item], path: String, handler: @escaping ResponseVoid) -> URLSessionTask? {
        let ids = items.map { $0.id }
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
    
    //MARK: - Delete
    
    @discardableResult
    func delete(items: [Item], handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("deleteItems")
        let uuids = items.compactMap { $0.uuid }
        return deleteItemsBy(uuids: uuids, handler: handler)
    }
    
    @discardableResult
    func deleteAlbums(_ albums: [AlbumItem], handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("deleteAlbums")
        let uuids = albums.compactMap { $0.uuid }
        return deleteItemsBy(uuids: uuids, handler: handler)
    }
    
    private func deleteItemsBy(uuids: [String], handler: @escaping ResponseVoid) -> URLSessionTask? {
        let path = RouteRequests.FileSystem.delete
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
    
    @discardableResult
    func deletePeople(items: [PeopleItem], handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("deletePeople")
        let path = RouteRequests.peopleDelete
        return deleteSmartAlbums(albums: items, path: path, handler: handler)
    }
    
    @discardableResult
    func deletePlaces(items: [PlacesItem], handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("deletePlaces")
        let path = RouteRequests.placesDelete
        return deleteSmartAlbums(albums: items, path: path, handler: handler)
    }
    
    @discardableResult
    func deleteThings(items: [ThingsItem], handler: @escaping ResponseVoid) -> URLSessionTask? {
        debugLog("deleteThings")
        let path = RouteRequests.thingsDelete
        return deleteSmartAlbums(albums: items, path: path, handler: handler)
    }

    private func deleteSmartAlbums(albums: [Item], path: String, handler: @escaping ResponseVoid) -> URLSessionTask? {
        let ids = albums.compactMap { $0.id }
        return deleteItemsBy(ids: ids, path: path, handler: handler)
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
}
