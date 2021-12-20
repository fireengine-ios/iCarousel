//
//  AlbumService.swift
//  Depo
//
//  Created by Oleg on 16.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Alamofire

struct AlbumsPatch {
    static let album = "album"
//    static let deleteAlbums =  "album/trash"
    static let addPhotosToAlbum = "album/addFiles/%@"
    static let deletePhotosFromAlbum = "album/removeFiles/%@"
    static let renameAlbum = "album/rename/%@?newLabel=%@"
    static let changeCoverPhoto = "album/coverPhoto/%@?coverPhotoUuid=%@"
    
    static let trashAlbums = "album/trash"
    static let getAlbumItemCount = "album/count/%@"
}

class CreatesAlbum: BaseRequestParametrs {
    
    let albumName: String
    
    init(albumName: String) {
        self.albumName = albumName
    }
    
    override var requestParametrs: Any {
        let dict: [String: Any] = [SearchJsonKey.albumName: albumName,
                                   SearchJsonKey.contentType: SearchJsonKey.contentTypeAlbum]
        return dict
    }
    
    override var patch: URL {
        let path: String = String(format: AlbumsPatch.album)
        return URL(string: path, relativeTo: super.patch)!
    }
}

class DeleteAlbums: BaseRequestParametrs {
    let albums: [AlbumItem]
    
    init (albums: [AlbumItem]) {
        self.albums = albums
    }
    
    override var requestParametrs: Any {
        let albumsUUIDS = albums.map { $0.uuid }
        return albumsUUIDS
    }
    
    override var patch: URL {
        let path: String = String(format: AlbumsPatch.album)
        return URL(string: path, relativeTo: super.patch)!
    }
}

class MoveToTrashAlbums: BaseRequestParametrs {
    let albums: [AlbumItem]
       
    init (albums: [AlbumItem]) {
       self.albums = albums
    }

    override var requestParametrs: Any {
       let albumsUUIDS = albums.map { $0.uuid }
       return albumsUUIDS
    }
    
    override var patch: URL {
        let path: String = String(format: AlbumsPatch.trashAlbums)
        return URL(string: path, relativeTo: super.patch)!
    }
}

class AddPhotosToAlbum: BaseRequestParametrs {
    let albumUUID: String
    let photos: [Item]
    
    init (albumUUID: String, photos: [Item]) {
        self.albumUUID = albumUUID
        self.photos = photos
    }
    
    override var requestParametrs: Any {
        let photosUUID = photos.map { $0.uuid }
        return photosUUID
    }
    
    override var patch: URL {
        let path: String = String(format: AlbumsPatch.addPhotosToAlbum, albumUUID)
        return URL(string: path, relativeTo: super.patch)!
    }
}

class ChangeCoverPhoto: BaseRequestParametrs {
    let albumUUID: String
    let photoUUID: String
    
    init (albumUUID: String, photoUUID: String) {
        self.albumUUID = albumUUID
        self.photoUUID = photoUUID
    }
    
    override var patch: URL {
        let path: String = String(format: AlbumsPatch.changeCoverPhoto, albumUUID, photoUUID)
        return URL(string: path, relativeTo: super.patch)!
    }
}

class DeletePhotosFromAlbum: AddPhotosToAlbum {
    override var patch: URL {
        let path: String = String(format: AlbumsPatch.deletePhotosFromAlbum, albumUUID)
        return URL(string: path, relativeTo: RouteRequests.baseUrl)!
    }
}

class RenameAlbum: BaseRequestParametrs {
    let albumUUID: String
    let newName: String
    
    init (albumUUID: String, newName: String) {
        self.albumUUID = albumUUID
        self.newName = newName
    }
    
    override var patch: URL {
        let path = String(format: AlbumsPatch.renameAlbum, albumUUID, newName)
        return URL.encodingURL(string: path, relativeTo: super.patch)!
    }
}


class AlbumService: RemoteItemsService {
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .albums)
    }
    
    func allAlbums(sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoteAlbums, fail:@escaping FailRemoteItems) {
        currentPage = 0
        requestSize = 90000
        nextItems(sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
    
    func nextItems(sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoteAlbums, fail:@escaping FailRemoteItems ) {
        debugLog("AlbumService nextItems")

        let serchParam = AlbumParameters(fieldName: contentType,
                                         sortBy: sortBy,
                                         sortOrder: sortOrder,
                                         page: currentPage,
                                         size: requestSize)
        
        remote.searchAlbums(param: serchParam, success: { [weak self] response in
            guard let resultResponse = response as? AlbumResponse else {
                return fail()
            }
            
            self?.currentPage += 1
            let list = resultResponse.list.compactMap { AlbumItem(remote: $0) }
            success(list)

        }, fail: { errorResponse in
            errorResponse.showInternetErrorGlobal()
            fail()
        })
    }
    
}

class GetAlbumItemCount: BaseRequestParametrs {
    let albumUUID: String

    init (albumUUID: String) {
        self.albumUUID = albumUUID
    }

    override var patch: URL {
        let path: String = String(format: AlbumsPatch.getAlbumItemCount, albumUUID)
        return URL(string: path, relativeTo: super.patch)!
    }
}

typealias AlbumCreatedOperation = (AlbumItem?) -> Void
typealias AlbumsSuccess = ([AlbumItem]) -> Void
typealias AlbumOperationResponse = (_ album: AlbumServiceResponse) -> Void
typealias PhotosAlbumOperation = () -> Void
typealias PhotosAlbumDeleteOperation = (_ deletedItems: [AlbumItem]) -> Void
typealias PhotosFromAlbumsOperation = (_ items: [Item]) -> Void
typealias PhotosByAlbumsOperation = (_ items: [AlbumItem: [Item]]) -> Void
typealias AlbumItemCountResponse = (_ itemCount: AlbumCountResponse) -> Void

class PhotosAlbumService: BaseRequestService {
    
    private lazy var albumService = AlbumDetailService(requestSize: Device.isIpad ? 200 : 100)
    
    func createAlbum(createAlbum: CreatesAlbum, success: AlbumCreatedOperation?, fail: FailResponse?) {
        debugLog("PhotosAlbumService createAlbum")

        let handler = BaseResponseHandler<AlbumServiceResponse, ObjectRequestResponse>(success: { response in
            if let albumResponse = response as? AlbumServiceResponse { 
                let item = AlbumItem(remote: albumResponse)
                success?(item)
            } else {
                success?(nil)
            }
        }, fail: fail)
        executePostRequest(param: createAlbum, handler: handler)
    }
    
    func delete(albums: [AlbumItem], success: PhotosAlbumDeleteOperation?, fail: FailResponse?) {
        debugLog("PhotosAlbumService deleteAlbums")

        let deleteAlbums = albums.filter { $0.readOnly != true || $0.fileType.isFaceImageAlbum }
        guard !deleteAlbums.isEmpty else {
            fail?(ErrorResponse.string(TextConstants.removeReadOnlyAlbumError))
            return
        }
        
        let params = DeleteAlbums(albums: deleteAlbums)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            success?(deleteAlbums)
        }, fail: fail)
        executeDeleteRequest(param: params, handler: handler)
    }
    
    func completelyDelete(albums: [AlbumItem], success: PhotosAlbumDeleteOperation?, fail: FailResponse?) {
        debugLog("PhotosAlbumService completelyDelete")
        
        let deleteAlbums = albums.filter { $0.readOnly != true || $0.fileType.isFaceImageAlbum }
        guard !deleteAlbums.isEmpty else {
            fail?(ErrorResponse.string(TextConstants.removeReadOnlyAlbumError))
            return
        }
        
        let wrappedSuccess: PhotosAlbumDeleteOperation = { deletedAlbums in
            success?(deletedAlbums)
            ItemOperationManager.default.albumsDeleted(albums: deletedAlbums)
        }
        
        loadAllItemsFrom(albums: deleteAlbums) { items in
            let fileService = WrapItemFileService()
            fileService.delete(deleteFiles: items, success: { [weak self] in
                self?.delete(albums: deleteAlbums, success: wrappedSuccess, fail: fail)
            }, fail: fail)
        }
    }
    
    func moveToTrash(albums: [AlbumItem], success: PhotosAlbumDeleteOperation?, fail: FailResponse?) {
        debugLog("PhotosAlbumService completelyMoveToTrash")
        
        let moveToTrashAlbums = albums.filter { $0.readOnly != true || $0.fileType.isFaceImageAlbum }
        guard !moveToTrashAlbums.isEmpty else {
            fail?(ErrorResponse.string(TextConstants.removeReadOnlyAlbumError))
            return
        }
        
        loadAllItemsFrom(albums: moveToTrashAlbums) { [weak self] items in
            self?.moveToTrash(albums: albums, albumItems: items, success: success, fail: fail)
        }
    }
    
    func moveToTrash(albums: [AlbumItem], albumItems: [Item], success: PhotosAlbumDeleteOperation?, fail: FailResponse?) {
        debugLog("PhotosAlbumService completelyMoveToTrash")

        let wrappedSuccess: PhotosAlbumDeleteOperation = { deletedAlbums in
            success?(deletedAlbums)
            ItemOperationManager.default.didMoveToTrashAlbums(deletedAlbums)
        }
        
        let fileService = WrapItemFileService()
        fileService.moveToTrash(files: albumItems, success: { [weak self] in
            self?.moveToTrashAlbums(albums, success: wrappedSuccess, fail: fail)
        }, fail: fail)
    }
    
    func addPhotosToAlbum(parameters: AddPhotosToAlbum, success: PhotosAlbumOperation?, fail: FailResponse?) {
        debugLog("PhotosAlbumService addPhotosToAlbum")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        //executePostRequest(param: parameters, handler: handler)
        executePutRequest(param: parameters, handler: handler)
    }
    
    func deletePhotosFromAlbum(parameters: DeletePhotosFromAlbum, success: PhotosAlbumOperation?, fail: FailResponse?) {
        debugLog("PhotosAlbumService deletePhotosFromAlbum")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        executePutRequest(param: parameters, handler: handler)
    }
    
    func changeCoverPhoto(parameters: ChangeCoverPhoto, success: PhotosAlbumOperation?, fail: FailResponse?) {
        debugLog("PhotosAlbumService changeCoverPhoto")
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { response  in
            success?()
        }, fail: fail)
        executePutRequest(param: parameters, handler: handler)
    }
    
    func changePeopleThumbnail(parameters: PeopleChangeThumbnailParameters, success: PhotosAlbumOperation?, fail: FailResponse?) {
        debugLog("PhotosAlbumService changePeopleThumbnail")
        
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { response  in
            success?()
        }, fail: fail)
        executePostRequest(param: parameters, handler: handler)
    }
    
    func renameAlbum(parameters: RenameAlbum, success: PhotosAlbumOperation?, fail: FailResponse?) {
        debugLog("PhotosAlbumService renameAlbum")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _ in
            success?()
        }, fail: fail)
        executePutRequest(param: parameters, handler: handler)
    }
    
    func loadAllItemsFrom(albums: [AlbumItem], success: PhotosFromAlbumsOperation?) {
        debugLog("PhotosAlbumService loadAllItemsFrom")

        guard albums.count > 0 else { success?([Item]()); return }
        let group = DispatchGroup()
        var allItems = [WrapData]()
        for album in albums {
            group.enter()
            albumService.allItems(albumUUID: album.uuid, sortBy: .name, sortOrder: .asc, success: { items in
                allItems.append(contentsOf: items)
                group.leave()
            }, fail: {
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) {
            success?(allItems)
        }
    }
    
    func loadItemsBy(albums: [AlbumItem], success: PhotosByAlbumsOperation?) {
        debugLog("PhotosAlbumService loadItemsBy")

        guard !albums.isEmpty else {
            success?([AlbumItem: [Item]]())
            return
        }
        
        let group = DispatchGroup()
        var allItems = [AlbumItem: [Item]]()
        for album in albums {
            group.enter()
            albumService.allItems(albumUUID: album.uuid, sortBy: .name, sortOrder: .asc, success: { items in
                allItems[album] = items
                group.leave()
            }, fail: {
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) {
            success?(allItems)
        }
    }
    
    func getAlbum(for uuid: String, handler: @escaping ResponseHandler<AlbumServiceResponse>) {
        let url = RouteRequests.baseUrl +/ "album/\(uuid)"
        SessionManager.customDefault
            .request(url)
            .responseObject(handler)
    }
    
    private func moveToTrashAlbums(_ albums: [AlbumItem], success: PhotosAlbumDeleteOperation?, fail: FailResponse?) {
        debugLog("PhotosAlbumService moveToTrashAlbums")

        let moveToTrashAlbums = albums.filter { $0.readOnly != true || $0.fileType.isFaceImageAlbum }
        guard !moveToTrashAlbums.isEmpty else {
            fail?(ErrorResponse.string(TextConstants.removeReadOnlyAlbumError))
            return
        }
        
        let params = MoveToTrashAlbums(albums: moveToTrashAlbums)
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            success?(moveToTrashAlbums)
        }, fail: fail)
        executeDeleteRequest(param: params, handler: handler)
    }

    func getAlbumItemCount(parameters: GetAlbumItemCount, success: AlbumItemCountResponse?, fail: FailResponse?) {
        debugLog("PhotosAlbumService getAlbumItemCount")

        let handler = BaseResponseHandler<AlbumCountResponse, ObjectRequestResponse>(success: { response  in
            if let response = response as? AlbumCountResponse {
                success?(response)
            }
        }, fail: fail)
        executeGetRequest(param: parameters, handler: handler)
    }
}

/// For UploadOperation
extension PhotosAlbumService {
    /// call only if serverErrorMessage is enough or pass real errors
    func createAlbums(names: [String], success: @escaping AlbumsSuccess, fail: @escaping FailResponse) {
        var albums = [AlbumItem]()
        
        let group = DispatchGroup()
        names.forEach {
            group.enter()
            
            let params = CreatesAlbum(albumName: $0)
            createAlbum(createAlbum: params, success: { item in
                if let item = item {
                    ItemOperationManager.default.newAlbumCreated()
                    albums.append(item)
                }
                
                group.leave()
                
            }, fail: { error in
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.global()) {
            if !albums.isEmpty {
                success(albums)
            } else {
                /// silence real errors
                fail(.string(TextConstants.serverErrorMessage))
            }
        }
    }
    
    func addItem(item: Item, to albums: [String], isAutoSync: Bool, completion: @escaping VoidHandler) {
        let group = DispatchGroup()
        
        albums.forEach {
            group.enter()
            let parameters = AddPhotosToAlbum(albumUUID: $0, photos: [item])
            
            addPhotosToAlbum(parameters: parameters, success: {
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AddToAlbum(status: .success))
                ItemOperationManager.default.filesAddedToAlbum(isAutoSyncOperation: isAutoSync)
                group.leave()
            }, fail: { _ in
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AddToAlbum(status: .failure))
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.global()) {
            completion()
        }
    }
}
