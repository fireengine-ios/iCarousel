//
//  MoreFilesActionsInteractor.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class MoreFilesActionsInteractor: NSObject, MoreFilesActionsInteractorInput {
    
    weak var output: MoreFilesActionsInteractorOutput?
    private var fileService = WrapItemFileService()
    
    let player: MediaPlayer = factory.resolve()
    let photosAlbumService = PhotosAlbumService()
    
    
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
        sync(items: sharingItems, action: { [weak self] in
            guard let `self` = self else { return }
            if self.sharingItems.contains(where: { return $0.fileType != .image && $0.fileType != .video }) {
                self.shareViaLink(sourceRect: sourceRect)
            } else {
                self.showSharingMenu(sourceRect: sourceRect)
            }
        }, cancel: {})
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
        if let items = sharingItems as? [WrapData] {
            let files: [FileForDownload] = items.flatMap({ FileForDownload(forMediumURL: $0) })
            shareFiles(filesForDownload: files, sourceRect: sourceRect)
        }
        
    }
    
    func shareOrignalSize(sourceRect: CGRect?){
        if let items = sharingItems as? [WrapData] {
            let files: [FileForDownload] = items.flatMap({ FileForDownload(forOriginalURL: $0) })
            shareFiles(filesForDownload: files, sourceRect: sourceRect)
        }
    }
    
    private func shareFiles(filesForDownload: [FileForDownload], sourceRect: CGRect?) {
        let downloader = FilesDownloader()
        output?.operationStarted(type: .share)
        
        downloader.getFiles(filesForDownload: filesForDownload, response: { [weak self] (fileURLs, directoryURL) in
                DispatchQueue.main.async {
                    self?.output?.operationFinished(type: .share)
                    
                    let activityVC = UIActivityViewController(activityItems: fileURLs, applicationActivities: nil)
                    
                    activityVC.completionWithItemsHandler = { (_, _, _, _) in
                        do {
                            try FileManager.default.removeItem(at: directoryURL)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                    if let tempoRect = sourceRect {//if ipad
                        activityVC.popoverPresentationController?.sourceRect = tempoRect
                    }
                    
                    let router = RouterVC()
                    router.presentViewController(controller: activityVC)
                }
            }, fail: { [weak self] (errorMessage) in
                self?.output?.operationFailed(type: .share, message: errorMessage)
        })
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
    
    
    private var cropyController: CRYCropNavigationController?
    
    func edit(item: [BaseDataSourceItem], complition: (() -> Void)?) {
        guard let item = item.first as? Item, let url = item.tmpDownloadUrl else {
            return
        }
        
        ImageDownloder().getImage(patch: url) { [weak self] image in
            guard let `self` = self, let image = image,
                let vc = CRYCropNavigationController.startEdit(with: image, andUseCropPage: false)
            else {
                complition?()
                return
            }
            
            //vc.setShareEnabled(true)
            //        vc.setCropDelegate(self)
            vc.sharedDelegate = self
            self.cropyController = vc
            
            complition?()
            RouterVC().presentViewController(controller: vc)
        }
    }
    
    func delete(item: [BaseDataSourceItem]) {
        if let items = item as? [Item] {
            deleteItems(items: items.filter({ !$0.isLocalItem }))
        } else if let albumbs = item as? [AlbumItem] {
            deleteAlbumbs(albumbs: albumbs)
        }
    }
    
    func completelyDelete(albums: [BaseDataSourceItem]) {
        let okHandler: () -> Void = { [weak self] in
            guard let albums = albums as? [AlbumItem] else { return }
            self?.output?.operationStarted(type: .completelyDeleteAlbums)
            let albumService = PhotosAlbumService()
            albumService.completelyDelete(albums: DeleteAlbums(albums: albums), success: {
                DispatchQueue.main.async { [weak self] in
                    self?.output?.operationFinished(type: .completelyDeleteAlbums)
                }
            }, fail: { [weak self] errorRespone in
                DispatchQueue.main.async {
                    self?.output?.operationFailed(type: .completelyDeleteAlbums, message: errorRespone.description)
                }
            })
        }
        
        let controller = PopUpController.with(title: TextConstants.actionSheetDelete,
                                              message: TextConstants.deleteAlbums,
                                              image: .delete,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              secondAction: { vc in
                                                vc.close(completion: okHandler)
        })
        
        RouterVC().presentViewController(controller: controller)
    }
    
    private func deleteItems(items: [Item]) {
        let okHandler: () -> Void = { [weak self] in
            self?.output?.operationStarted(type: .delete)
            self?.player.remove(listItems: items)
            self?.fileService.delete(deleteFiles: items,
            success: self?.succesAction(elementType: .delete),
            fail: self?.failAction(elementType: .delete))
        }
        
        let controller = PopUpController.with(title: TextConstants.actionSheetDelete,
                                              message: TextConstants.deleteFilesText,
                                              image: .delete,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              secondAction: { vc in
                                                vc.close(completion: okHandler)
        })
        
        RouterVC().presentViewController(controller: controller)
    }
    
    private func deleteAlbumbs(albumbs: [AlbumItem]) {
        let okHandler: () -> Void = { [weak self] in
            self?.output?.operationStarted(type: .removeFromAlbum)
            let albumService = PhotosAlbumService()
            albumService.deleteAlbums(deleteAlbums: DeleteAlbums(albums: albumbs), success: { [weak self] in
                DispatchQueue.main.async {
                    self?.output?.operationFinished(type: .removeAlbum)
                    ItemOperationManager.default.albumsDeleted(albums: albumbs)
                }
            }, fail: { [weak self] errorRespone in
                DispatchQueue.main.async {
                    self?.output?.operationFailed(type: .removeAlbum, message: errorRespone.description)
                }
            })
        }
        
        let controller = PopUpController.with(title: TextConstants.actionSheetRemove,
                                              message: TextConstants.removeAlbums,
                                              image: .delete,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              secondAction: { vc in
                                                vc.close(completion: okHandler)
        })
        
        RouterVC().presentViewController(controller: controller)
    }
    
    private func deleteFromAlbums(items: [BaseDataSourceItem]){
        let okHandler: () -> Void = { [weak self] in
            self?.output?.operationStarted(type: .removeFromAlbum)
            
            var album = ""
            
            for item in items {
                if let item = item as? WrapData, let albumID = item.albums?.first {
                    album = albumID
                    break
                }
            }
            
            let parameters = DeletePhotosFromAlbum(albumUUID: album, photos: items as! [Item])
            PhotosAlbumService().deletePhotosFromAlbum(parameters: parameters, success: { [weak self] in
                DispatchQueue.main.async {
                    self?.output?.operationFinished(type: .removeFromAlbum)
                }
            }) { [weak self] errorRespone in
                DispatchQueue.main.async {
                    self?.output?.operationFailed(type: .removeFromAlbum, message: errorRespone.description)
                }
            }
        }
        
        let controller = PopUpController.with(title: TextConstants.actionSheetRemove,
                                              message: TextConstants.removeFromAlbum,
                                              image: .delete,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              secondAction: { vc in
                                                vc.close(completion: okHandler)
        })
        
        RouterVC().presentViewController(controller: controller)
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
            
            }, cancel: { [weak self] in
                self?.succesAction(elementType: ElementTypes.move)()
        } )
    }
    
    func copy(item: [BaseDataSourceItem], toPath: String) {
        guard let item = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        let router = RouterVC()
        let folderSelector = router.selectFolder(folder: nil)
        
        
        folderSelector.selectFolder(select: { [weak self] (folder) in
            self?.fileService.move(items: item, toPath: folder.uuid,
                                   success: self?.succesAction(elementType: .copy),
                                   fail: self?.failAction(elementType: .copy))
            }, cancel: { [weak self] in
                self?.succesAction(elementType: ElementTypes.move)()
        })
    }
    
    func sync(item: [BaseDataSourceItem]) {
        guard let item = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        
        fileService.upload(items: item, toPath: "",
                           success: succesAction(elementType: .sync),
                           fail: failAction(elementType: .sync))
    }
    
    func download(item: [BaseDataSourceItem]) {
        if let item = item as? [Item] { //FIXME: transform all to BaseDataSourceItem
            fileService.download(items: item, toPath: "",
                                 success: succesAction(elementType: .download),
                                 fail: failAction(elementType: .download))
        } else if let albums = item as? [AlbumItem] {
            
            photosAlbumService.loadItemsBy(albums: albums, success: {[weak self] (itemsByAlbums) in
                self?.fileService.download(itemsByAlbums: itemsByAlbums,
                                          success: self?.succesAction(elementType: .download),
                                          fail: self?.failAction(elementType: .download))
            })
        }
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
        guard let items = items.filter({ !$0.isLocalItem }) as? [WrapData], items.count > 0 else { return }
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
        sync(items: items, action: {
            let router = RouterVC()
            let vc = router.addPhotosToAlbum(photos: items)
            DispatchQueue.main.async {
                router.pushViewController(viewController: vc)
            }
        }, cancel: {})
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
        guard items.count > 0 else { return }
        sharingItems.removeAll()
        sharingItems.append(contentsOf: items)
        shareViaLink(sourceRect: nil)
    }
    
    func makeAlbumCover(items: [BaseDataSourceItem]) {
        
    }
    
    func albumDetails(items: [BaseDataSourceItem]) {
        let router = RouterVC()
        let albumDetailVC = router.fileInfo as? FileInfoViewController
        albumDetailVC?.interactor.setObject(object: items.first!)
        router.pushViewController(viewController: albumDetailVC!)
    }
    
    func downloadToCmeraRoll(items: [BaseDataSourceItem]) {
        download(item: items)
    }
    
    func deleteDeviceOriginal(items: [BaseDataSourceItem]) {
        guard let wrapedItems = items as? [WrapData] else {
            return
        }
        fileService.deleteLocalFiles(deleteFiles: wrapedItems, success: succesAction(elementType: .deleteDeviceOriginal),
                                     fail: failAction(elementType: .deleteDeviceOriginal))
    }
    
    func succesAction(elementType: ElementTypes) -> FileOperation {
        let success: FileOperation = { [weak self] in
            DispatchQueue.main.async {
                self?.output?.operationFinished(type: elementType)
                
                let text: String
                switch elementType {
                case .download:
                    text = TextConstants.popUpDownloadComplete
                case .delete:
                    text = TextConstants.popUpDeleteComplete
                default:
                    return
                }
                UIApplication.showSuccessAlert(message: text)
            }
        }
        return success
    }
    
    func failAction(elementType: ElementTypes) -> FailResponse {
        
        let failResponse : FailResponse  = { [weak self] value in
            DispatchQueue.main.async {
                self?.output?.operationFailed(type: elementType, message: value.description)
            }
        }
        return failResponse
    }
    
    private func sync(items: [BaseDataSourceItem], action: @escaping () -> Void, cancel: @escaping () -> Void, fail: FailResponse? = nil) {
        guard let items = items as? [WrapData] else { return }
        let successClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.output?.compliteAsyncOperationEnableScreen()
                action()
            }
        }
        let failClosure: FailResponse = { [weak self] (errorResponse) in
            DispatchQueue.main.async {
                self?.output?.compliteAsyncOperationEnableScreen()
                fail?(errorResponse)
            }
        }
        let operations = fileService.syncItemsIfNeeded(items, success: successClosure, fail: failClosure)
        if let operations = operations {
            output?.startCancelableAsync(operations: operations, cancel: cancel)
        }
    }
}


// MARK: - Cropy delegate
/// https://wiki.life.com.by/pages/viewpage.action?spaceKey=LTFizy&title=Cropy
/// https://stash.turkcell.com.tr/git/projects/CROP/repos/cropy-ios-sdk/browse
extension MoreFilesActionsInteractor: TOCropViewControllerDelegate {
    
    @objc func getEditedImage(_ image: UIImage) {
        
        let vc = PopUpController.with(title: TextConstants.save, message: TextConstants.cropyMessage, image: .error, firstButtonTitle: TextConstants.cancel, secondButtonTitle: TextConstants.ok, secondAction: { [weak self] vc in
            self?.save(image: image)
            vc.close { [weak self] in
                self?.cropyController?.dismiss(animated: true, completion: nil)
            }
        })
        UIApplication.topController()?.present(vc, animated: false, completion: nil)
    }
    
    private func save(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
