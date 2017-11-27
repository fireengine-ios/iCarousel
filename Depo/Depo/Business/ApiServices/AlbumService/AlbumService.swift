//
//  AlbumService.swift
//  Depo
//
//  Created by Oleg on 16.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct AlbumsPatch  {
    
    static let album =  "/api/album"
    static let deleteAlbumss =  "/api/album"
    static let addPhotosToAlbum = "/api/album/addFiles/%@"
    static let deletePhotosFromAlbum = "/api/album/removeFiles/%@"
    static let renameAlbum = "/api/album/rename/%@&newLabel=%@"
    
}

class CreatesAlbum: BaseRequestParametrs {
    
    let albumName: String
    
    init(albumName: String) {
        self.albumName = albumName
    }
    
    override var requestParametrs: Any {
        let dict: [String: Any] = [SearchJsonKey.albumName: albumName, SearchJsonKey.contentType: SearchJsonKey.contentTypeAlbum]
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
        let path: String = String(format: AlbumsPatch.renameAlbum, albumUUID, newName)
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
            let list = resultResponse.list.flatMap { AlbumItem(remote: $0) }
            success(list)
        }, fail: { _ in
            fail()
        })
    }
    
}



typealias PhotosAlbumOperation = () -> Swift.Void

class PhotosAlbumService: BaseRequestService {
    
    func createAlbum(createAlbum: CreatesAlbum, success: PhotosAlbumOperation?, fail: FailResponse?){
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        executePostRequest(param: createAlbum, handler: handler)
    }
    
    func deleteAlbums(deleteAlbums: DeleteAlbums, success: PhotosAlbumOperation?, fail: FailResponse?){
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        executeDeleteRequest(param: deleteAlbums, handler: handler)
    }
    
    func addPhotosToAlbum(parameters: AddPhotosToAlbum, success: PhotosAlbumOperation?, fail: FailResponse?){
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        //executePostRequest(param: parameters, handler: handler)
        executePutRequest(param: parameters, handler: handler)
    }
    
    func deletePhotosFromAlbum(parameters: DeletePhotosFromAlbum, success: PhotosAlbumOperation?, fail: FailResponse?){
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        executePutRequest(param: parameters, handler: handler)
    }
    
    func renameAlbum(parameters: RenameAlbum, success: PhotosAlbumOperation?, fail: FailResponse?){
        let handler = BaseResponseHandler<ObjectRequestResponse, ObjectRequestResponse>(success: { _  in
            success?()
        }, fail: fail)
        executePutRequest(param: parameters, handler: handler)
    }
    
}
