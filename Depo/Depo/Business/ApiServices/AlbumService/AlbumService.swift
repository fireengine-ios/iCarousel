//
//  AlbumService.swift
//  Depo
//
//  Created by Oleg on 16.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct AlbumsPatch  {
    static let album =  "/api/album"
//    static let deleteAlbumss =  "/api/album"
    static let addPhotosToAlbum = "/api/album/addFiles/%@"
    static let deletePhotosFromAlbum = "/api/album/removeFiles/%@"
    static let renameAlbum = "/api/album/rename/%@?newLabel=%@"
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
        let path: String = String(format:AlbumsPatch.album)
        return URL(string: path, relativeTo:super.patch)!
    }
}

class DeleteAlbums: BaseRequestParametrs {
    let albums: [AlbumItem]
    
    init (albums: [AlbumItem]){
        self.albums = albums
    }
    
    override var requestParametrs: Any{
        let albumsUUIDS = albums.map { $0.uuid }
        return albumsUUIDS
    }
    
    override var patch: URL {
        let path: String = String(format: AlbumsPatch.album)
        return URL(string: path, relativeTo: super.patch)!
    }
}

class AddPhotosToAlbum: BaseRequestParametrs {
    let albumUUID: String
    let photos: [Item]
    
    init (albumUUID: String, photos: [Item]){
        self.albumUUID = albumUUID
        self.photos = photos
    }
    
    override var requestParametrs: Any{
        let photosUUID = photos.map { $0.uuid }
        return photosUUID
    }
    
    override var patch: URL {
        let path: String = String(format: AlbumsPatch.addPhotosToAlbum, albumUUID)
        return URL(string: path, relativeTo: super.patch)!
    }
}

class DeletePhotosFromAlbum: AddPhotosToAlbum{
    override var patch: URL {
        let path: String = String(format: AlbumsPatch.deletePhotosFromAlbum, albumUUID)
        return URL(string: path, relativeTo: super.patch)!
    }
}

class RenameAlbum: BaseRequestParametrs {
    let albumUUID: String
    let newName: String
    
    init (albumUUID: String, newName: String){
        self.albumUUID = albumUUID
        self.newName = newName
    }
    
    override var patch: URL {
        let encodingName = newName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? newName
        let path: String = String(format: AlbumsPatch.renameAlbum, albumUUID, encodingName)
        return URL(string: path, relativeTo: super.patch)!
    }
}


class AlbumService: RemoteItemsService {
    init(requestSize: Int) {
        super.init(requestSize: requestSize, fieldValue: .albums)
    }
    
    func allAlbums(sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoveAlbums, fail:@escaping FailRemoteItems) {
        currentPage = 0
        requestSize = 90000
        nextItems(sortBy: sortBy, sortOrder: sortOrder, success: success, fail: fail)
    }
    
    func nextItems(sortBy: SortType, sortOrder: SortOrder, success: @escaping ListRemoveAlbums, fail:@escaping FailRemoteItems ) {
        log.debug("AlbumService nextItems")

        let serchParam = AlbumParameters(fieldName: contentType,
                                         sortBy: sortBy,
                                         sortOrder: sortOrder,
                                         page: currentPage,
                                         size: requestSize)
        
        remote.searchAlbums(param: serchParam, success: { [weak self] response in
            guard let resultResponse = response as? AlbumResponse else {
                log.debug("AlbumService remote searchAlbums fail")

                return fail()
            }
            
            log.debug("AlbumService remote searchAlbums success")
            
            self?.currentPage += 1
            let list = resultResponse.list.flatMap { AlbumItem(remote: $0) }
            success(list)
        }, fail: { errorResponse in
            errorResponse.showInternetErrorGlobal()
            log.debug("AlbumService remote searchAlbums fail")

            fail()
        })
    }
    
}



typealias PhotosAlbumOperation = () -> Swift.Void
typealias PhotosFromAlbumsOperation = (_ items: [Item]) -> Swift.Void
typealias PhotosByAlbumsOperation = (_ items: [AlbumItem: [Item]]) -> Swift.Void

class PhotosAlbumService: BaseRequestService {
    
    func createAlbum(createAlbum: CreatesAlbum, success: PhotosAlbumOperation?, fail: FailResponse?) {
        log.debug("PhotosAlbumService createAlbum")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            log.debug("PhotosAlbumService createAlbum success")

            success?()
        }, fail: fail)
        executePostRequest(param: createAlbum, handler: handler)
    }
    
    func deleteAlbums(deleteAlbums: DeleteAlbums, success: PhotosAlbumOperation?, fail: FailResponse?) {
        log.debug("PhotosAlbumService deleteAlbums")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            log.debug("PhotosAlbumService deleteAlbums success")

            success?()
        }, fail: fail)
        executeDeleteRequest(param: deleteAlbums, handler: handler)
    }
    
    func completelyDelete(albums: DeleteAlbums, success: PhotosAlbumOperation?, fail: FailResponse?) {
        log.debug("PhotosAlbumService completelyDelete")

        loadAllItemsFrom(albums: albums.albums) { (items) in
            log.debug("PhotosAlbumService loadAllItemsFrom")

            let fileService = WrapItemFileService()
            fileService.delete(deleteFiles: items, success: nil, fail: nil)
            self.deleteAlbums(deleteAlbums: albums, success: success, fail: fail)
        }
    }
    
    func addPhotosToAlbum(parameters: AddPhotosToAlbum, success: PhotosAlbumOperation?, fail: FailResponse?){
        log.debug("PhotosAlbumService addPhotosToAlbum")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            log.debug("PhotosAlbumService addPhotosToAlbum success")

            success?()
        }, fail: fail)
        //executePostRequest(param: parameters, handler: handler)
        executePutRequest(param: parameters, handler: handler)
    }
    
    func deletePhotosFromAlbum(parameters: DeletePhotosFromAlbum, success: PhotosAlbumOperation?, fail: FailResponse?) {
        log.debug("PhotosAlbumService deletePhotosFromAlbum")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            log.debug("PhotosAlbumService deletePhotosFromAlbum success")

            success?()
        }, fail: fail)
        executePutRequest(param: parameters, handler: handler)
    }
    
    func renameAlbum(parameters: RenameAlbum, success: PhotosAlbumOperation?, fail: FailResponse?) {
        log.debug("PhotosAlbumService renameAlbum")

        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            log.debug("PhotosAlbumService renameAlbum success")

            success?()
        }, fail: fail)
        executePutRequest(param: parameters, handler: handler)
    }
    
    func loadAllItemsFrom(albums: [AlbumItem], success: PhotosFromAlbumsOperation?) {
        log.debug("PhotosAlbumService loadAllItemsFrom")

        guard albums.count > 0 else { success?([Item]()); return }
        let group = DispatchGroup()
        var allItems = [WrapData]()
        for album in albums {
            group.enter()
            let albumService = AlbumDetailService(requestSize: 100)
            albumService.allItems(albumUUID: album.uuid, sortBy: .name, sortOrder: .asc, success: { (items) in
                log.debug("PhotosAlbumService loadAllItemsFrom albumService allItems success")

                allItems.append(contentsOf: items)
                group.leave()
            }, fail: {
                log.debug("PhotosAlbumService loadAllItemsFrom AlbumDetailService allItems fail")

                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) {
            log.debug("PhotosAlbumService loadAllItemsFrom success")

            success?(allItems)
        }
    }
    
    func loadItemsBy(albums: [AlbumItem], success: PhotosByAlbumsOperation?) {
        log.debug("PhotosAlbumService loadItemsBy")

        guard albums.count > 0 else { success?([AlbumItem: [Item]]()); return }
        let group = DispatchGroup()
        var allItems = [AlbumItem: [Item]]()
        for album in albums {
            group.enter()
            let albumService = AlbumDetailService(requestSize: 100)
            albumService.allItems(albumUUID: album.uuid, sortBy: .name, sortOrder: .asc, success: { (items) in
                log.debug("PhotosAlbumService loadItemsBy AlbumDetailService allItems success")

                allItems[album] = items
                group.leave()
            }, fail: {
                log.debug("PhotosAlbumService loadItemsBy AlbumDetailService allItems fail")

                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) {
            success?(allItems)
        }
    }
    
}
