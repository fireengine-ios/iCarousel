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
    
    let player: MediaPlayer = factory.resolve()

    typealias FailResponse = (_ value: ErrorResponse) -> Swift.Void
    
    var sharingItems = [BaseDataSourceItem]()
    
    func share(item: [BaseDataSourceItem], sourceRect: CGRect?) {
        if (item.count == 0){
            return
        }
        sharingItems.removeAll()
        sharingItems.append(contentsOf: item)
        
        selectShareType(sourceRect: sourceRect)
    }
    
    func selectShareType(sourceRect: CGRect?) {
        if sharingItems.contains(where: { return $0.fileType != .image && $0.fileType != .video }) {
            shareViaLink(sourceRect: sourceRect)
        } else {
            showSharingMenu(sourceRect: sourceRect)
        }
    }
    
    func showSharingMenu(sourceRect: CGRect?) {
        let controler = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controler.view.tintColor = ColorConstants.darcBlueColor
        
        let smallAction = UIAlertAction(title: TextConstants.actionSheetShareSmallSize, style: .default) { (action) in
            self.shareSmallSize(sourceRect: sourceRect)
        }
        
        controler.addAction(smallAction)
        
        let originalAction = UIAlertAction(title: TextConstants.actionSheetShareOriginalSize, style: .default) { (action) in
            self.shareOrignalSize(sourceRect: sourceRect)
        }
        controler.addAction(originalAction)
        
        let shareViaLinkAction = UIAlertAction(title: TextConstants.actionSheetShareShareViaLink, style: .default) { (action) in
            self.shareViaLink(sourceRect: sourceRect)
        }
        controler.addAction(shareViaLinkAction)
        
        let cancelAction = UIAlertAction(title: TextConstants.actionSheetShareCancel, style: .cancel, handler: nil)
        controler.addAction(cancelAction)
        
        if let tempoRect = sourceRect {//if ipad
            controler.popoverPresentationController?.sourceRect = tempoRect
        }
        
        let router = RouterVC()
        router.presentViewController(controller: controler)
    }
    
    func shareSmallSize(sourceRect: CGRect?){
        if let array = sharingItems as? [WrapData]{
            let imagesArray: [ImageForDowload] = array.flatMap({
                let image = ImageForDowload()
                image.downloadURL = $0.metaData?.smalURl
                image.imageName = $0.name
                return image
            })
            shareImagesByURLs(images: imagesArray, sourceRect: sourceRect)
        }
    }
    
    func shareOrignalSize(sourceRect: CGRect?){
        if let array = sharingItems as? [WrapData]{
            let imagesArray: [ImageForDowload] = array.flatMap({
                let image = ImageForDowload()
                image.downloadURL = $0.urlToFile
                image.imageName = $0.name
                return image
            })
            shareImagesByURLs(images: imagesArray, sourceRect: sourceRect)
        }
    }
    
    private func shareImagesByURLs(images: [ImageForDowload], sourceRect: CGRect?){
        let downloader = ImageDownloder()
        output?.operationStarted(type: .share)
        
        downloader.getImagesByImagesURLs(list: images) { [weak self] (imagesArray) in
            DispatchQueue.main.async {
                self?.output?.operationFinished(type: .share)
                
                let activityVC = UIActivityViewController(activityItems: imagesArray, applicationActivities: nil)
                
                if let tempoRect = sourceRect {//if ipad
                    activityVC.popoverPresentationController?.sourceRect = tempoRect
                }
                
                let router = RouterVC()
                router.presentViewController(controller: activityVC)
            }
        }
    }
    
    func shareViaLink(item: [BaseDataSourceItem], sourceRect: CGRect?) {
        if (item.count == 0){
            return
        }
        sharingItems.removeAll()
        sharingItems.append(contentsOf: item)
        
        shareViaLink(sourceRect: sourceRect)
    }
    
    func shareViaLink(sourceRect: CGRect?){
        output?.operationStarted(type: .share)
        fileService.share(sharedFiles: sharingItems, success: {[weak self] (url) in
            DispatchQueue.main.async {
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
    
    func info(item: [BaseDataSourceItem], isRenameMode: Bool) {
        self.output?.operationFinished(type: .info)
        
        let router = RouterVC()
        
        if let infoController = router.fileInfo as? FileInfoViewController, let object = item.first {
            infoController.interactor.setObject(object: object)
            router.pushViewController(viewController: infoController)
            if isRenameMode {
                infoController.startRenaming()
            }
        }
    }
    
    func edit(item: [BaseDataSourceItem]) {
        
    }
    
    func delete(item: [BaseDataSourceItem]) {
        if let items = item as? [Item] {
            deleteItems(items: items.filter({ !$0.isLocalItem }))
        } else if let albumbs = item as? [AlbumItem] {
            deleteAlbumbs(albumbs: albumbs)
        }
    }
    
    private func deleteItems(items: [Item]) {
        output?.operationStarted(type: .delete)
        player.remove(listItems: items)
//        SingleSong.default.remove(items: items)
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
        
        var album = ""
        
        for item in items {
            if let item = item as? WrapData, let albumID = item.albums?.first {
                album = albumID
                break
            }
        }
        
        let parameters = DeletePhotosFromAlbum(albumUUID: album, photos: items as! [Item])
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
        let router = RouterVC()
        sync(items: items, action: {
            DispatchQueue.main.async {
                router.createStoryName(items: items)
            }
        }, cancel: {})
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
        let router = RouterVC()
        let vc = router.addPhotosToAlbum(photos: items)
        router.pushViewController(viewController: vc)
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
        download(item: items)
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
    
    private func sync(items: [BaseDataSourceItem], action: @escaping () -> Void, cancel: @escaping () -> Void, fail: FailResponse? = nil) {
        guard let items = items as? [WrapData] else { return }
        let successClosure = { [weak self] in
            self?.output?.compliteAsyncOperationEnableScreen()
            action()
        }
        let failClosure: FailResponse = { [weak self] (errorResponse) in
            self?.output?.compliteAsyncOperationEnableScreen()
            fail?(errorResponse)
        }
        let operations = fileService.syncItemsIfNeeded(items, success: successClosure, fail: failClosure)
        if let operations = operations {
            output?.startCancelableAsync(operations: operations, cancel: cancel)
        }
    }
}
