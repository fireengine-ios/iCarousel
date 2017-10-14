//
//  MoreFilesActionsInteractor.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class MoreFilesActionsInteractor: MoreFilesActionsInteractorInput {
    
    weak var output: MoreFilesActionsInteractorOutput?
    private var fileService = WrapItemFileService()

    typealias FailResponse = (_ value: ErrorResponse) -> Swift.Void
    
    func share(item: [BaseDataSourceItem], sourceRect: CGRect?) {
        output?.operationStarted(type: .share)
        fileService.share(sharedFiles: item, success: {(url) in
            
            DispatchQueue.main.async { [weak self] in
                
                self?.output?.operationFinished(type: .share)
                
                let objectsToShare = [url]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                if let tempoRect = sourceRect {//if ipad
                    activityVC.popoverPresentationController?.sourceRect = tempoRect
                }
                
                let router = RouterVC()
                router.presentViewController(controller: activityVC)
            }
            
        }, fail: failAction(elementType: .share))
    }
    
    func info(item: [BaseDataSourceItem]) {
        
    }
    
    func edit(item: [BaseDataSourceItem]) {
        
    }
    
    func delete(item: [BaseDataSourceItem]) {
        if let items = item as? [Item] {
            deleteItems(items: items)
        } else if let albumbs = item as? [AlbumItem] {
            deleteAlbumbs(albumbs: albumbs)
        }
        
        
    }
    
    private func deleteItems(items: [Item]) {
        output?.operationStarted(type: .delete)
        fileService.delete(deleteFiles: items,
                           success: succesAction(elementType: .delete),
                           fail: failAction(elementType: .delete))
        
    }
    
    private func deleteAlbumbs(albumbs: [AlbumItem]) {

        self.output?.operationStarted(type: .removeFromAlbum)
        let albumService = PhotosAlbumService()
        albumService.deleteAlbums(deleteAlbums: DeleteAlbums(albums: albumbs), success: {
            DispatchQueue.main.async { [weak self] in
                self?.output?.operationFinished(type: .removeFromAlbum)
            }
        }, fail: { errorRespone in
            DispatchQueue.main.async { [weak self] in
                
                self?.output?.operationFailed(type: .removeFromAlbum, message: errorRespone.description)
            }
        })
    }
    
    private func deleteFromAlbums(items: [BaseDataSourceItem]){
        self.output?.operationStarted(type: .removeFromAlbum)
        
        let parameters = DeletePhotosFromAlbum(albumUUID: "", photos: items as! [Item])
        PhotosAlbumService().deletePhotosFromAlbum(parameters: parameters, success: {
            DispatchQueue.main.async { [weak self] in
                self?.output?.operationFinished(type: .removeFromAlbum)
            }
        }) { (errorRespone) in
            DispatchQueue.main.async { [weak self] in
                
                self?.output?.operationFailed(type: .removeFromAlbum, message: errorRespone.description)
            }
        }
    }
    
    func move(item: [BaseDataSourceItem], toPath:String) {
        guard let item = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        let router = RouterVC()
        let folderSelector = router.selectFolder(folder: nil)
        
        
        folderSelector.selectFolder(select: { [weak self] (folder) in
            self?.output?.operationStarted(type: .move)
            self?.fileService.move(items: item, toPath: folder.uuid,
                                   success: self?.succesAction(elementType: .move),
                                   fail: self?.failAction(elementType: .move))
            
            }, cancel: { self.succesAction(elementType: ElementTypes.move)()
        } )
    }
    
    func copy(item: [BaseDataSourceItem], toPath:String) {
        guard let item = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        let router = RouterVC()
        let folderSelector = router.selectFolder(folder: nil)
        
        
        folderSelector.selectFolder(select: { [weak self] (folder) in
            
            self?.fileService.move(items: item, toPath: folder.uuid,
                                   success: self?.succesAction(elementType: .copy),
                                   fail: self?.failAction(elementType: .copy))
            
            }, cancel: { self.succesAction(elementType: ElementTypes.move)() } )
    }
    
    func sync(item: [BaseDataSourceItem]) {
        guard let item = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        
        //output?.operationStarted(type: .sync)
        
        fileService.upload(items: item, toPath: "",
                           success: succesAction(elementType: .sync),
                           fail: failAction(elementType: .sync))
    }
    
    func download(item: [BaseDataSourceItem]) {
        guard let item = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        //output?.operationStarted(type: .download)
        
        fileService.download(items: item, toPath: "",
                             success: succesAction(elementType: .download),
                             fail: failAction(elementType: .download))
    }
    
    func createStory(items: [BaseDataSourceItem]) {
        
    }
    
    func addToFavorites(items: [BaseDataSourceItem]) {
        guard let items = items as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        output?.operationStarted(type: .addToFavorites)
        fileService.addToFavourite(files: items,
                                   success: succesAction(elementType: .addToFavorites),
                                   fail: failAction(elementType: .addToFavorites))
    }
    
    func removeFromFavorites(items: [BaseDataSourceItem]) {
        guard let items = items as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        output?.operationStarted(type: .removeFromFavorites)
        fileService.removeFromFavourite(files: items,
                                        success:succesAction(elementType: .removeFromFavorites),
                                        fail: failAction(elementType: .removeFromFavorites))
    }
    
    
    // Photo Action
    
    func addToAlbum(items: [BaseDataSourceItem]) {
        
    }
    
    func backUp(items: [BaseDataSourceItem]) {
        
    }
    
    func removeFromAlbum(items: [BaseDataSourceItem]) {
        deleteFromAlbums(items: items)
    }
    
    func photos(items: [BaseDataSourceItem]) {
        
    }
    
    func iCloudDrive(items: [BaseDataSourceItem]) {
        
    }
    
    func lifeBox(items: [BaseDataSourceItem]) {
        
    }
    
    func more(items: [BaseDataSourceItem]) {
        
    }
    
    func select(items: [BaseDataSourceItem]) {
        //??????
    }
    
    func selectAll(items: [BaseDataSourceItem]) {
        //??????
    }
    
    func documentDetails(items: [BaseDataSourceItem]) {
        
    }
    
    func addToPlaylist(items: [BaseDataSourceItem]) {
        
    }
    
    func musicDetails(items: [BaseDataSourceItem]) {
        
    }
    
    func shareAlbum(items: [BaseDataSourceItem]) {
        
    }
    
    func makeAlbumCover(items: [BaseDataSourceItem]) {
        
    }
    
    func albumDetails(items: [BaseDataSourceItem]) {
        
    }
    
    func downloadToCmeraRoll(items: [BaseDataSourceItem]) {
        
    }
    
    func succesAction(elementType: ElementTypes) -> FileOperation {
        let succes : FileOperation = {
            DispatchQueue.main.async { [weak self] in
                self?.output?.operationFinished(type: elementType)
            }
        }
        return succes
    }
    
    func failAction(elementType: ElementTypes) -> FailResponse {
        
        let failResponse : FailResponse  = { value in
            DispatchQueue.main.async { [weak self] in
                self?.output?.operationFailed(type: elementType, message: value.description)
            }
        }
        return failResponse
    }
}
