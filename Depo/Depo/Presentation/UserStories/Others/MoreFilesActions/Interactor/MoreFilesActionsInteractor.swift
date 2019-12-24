//
//  MoreFilesActionsInteractor.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class MoreFilesActionsInteractor: NSObject, MoreFilesActionsInteractorInput {
    
    weak var output: MoreFilesActionsInteractorOutput?
    
    lazy var player: MediaPlayer = factory.resolve()
    
    private let router = RouterVC()
    
    private var fileService = WrapItemFileService()
    private let photosAlbumService = PhotosAlbumService()
    private let albumService = PhotosAlbumService()
    private let peopleService = PeopleService()
    private let thingsService = ThingsService()
    private let placesService = PlacesService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var hiddenService = HiddenService()

    private lazy var hideFunctionalityService: HideFuncServiceProtocol = HideFunctionalityService()
    
    typealias FailResponse = (_ value: ErrorResponse) -> Void
    
    var sharingItems = [BaseDataSourceItem]()
    
    func share(item: [BaseDataSourceItem], sourceRect: CGRect?) {
        if (item.count == 0) {
            return
        }
        sharingItems.removeAll()
        sharingItems.append(contentsOf: item)
        
        selectShareType(sourceRect: sourceRect)
    }
    
    func selectShareType(sourceRect: CGRect?) {
        if self.sharingItems.contains(where: { return $0.fileType != .image && $0.fileType != .video }) {
            self.shareViaLink(sourceRect: sourceRect)
        } else {
            self.showSharingMenu(sourceRect: sourceRect)
        }
    }
    
    func showSharingMenu(sourceRect: CGRect?) {
        let controler = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controler.view.tintColor = ColorConstants.darkBlueColor
        
        if sharingItems.count <= NumericConstants.numberOfSelectedItemsBeforeLimits {
            let smallAction = UIAlertAction(title: TextConstants.actionSheetShareSmallSize, style: .default) { [weak self] action in
                MenloworksAppEvents.onShareClicked()
                self?.sync(items: self?.sharingItems, action: { [weak self] in
                    self?.shareSmallSize(sourceRect: sourceRect)
                    }, cancel: {}, fail: { errorResponse in
                        UIApplication.showErrorAlert(message: errorResponse.description)
                })
            }
            
            controler.addAction(smallAction)
            
            let originalAction = UIAlertAction(title: TextConstants.actionSheetShareOriginalSize, style: .default) { [weak self] action in
                MenloworksAppEvents.onShareClicked()
                self?.sync(items: self?.sharingItems, action: { [weak self] in
                    self?.shareOrignalSize(sourceRect: sourceRect)
                    }, cancel: {}, fail: { errorResponse in
                        UIApplication.showErrorAlert(message: errorResponse.description)
                })
            }
            controler.addAction(originalAction)
        }
        
        let shareViaLinkAction = UIAlertAction(title: TextConstants.actionSheetShareShareViaLink, style: .default) { [weak self] action in
            MenloworksAppEvents.onShareClicked()
            
            self?.sync(items: self?.sharingItems, action: { [weak self] in
                self?.shareViaLink(sourceRect: sourceRect)
            }, cancel: {}, fail: { errorResponse in
                debugLog("sync(items: \(errorResponse.description)")
                UIApplication.showErrorAlert(message: errorResponse.description)
            })
        }
        controler.addAction(shareViaLinkAction)
        
        let cancelAction = UIAlertAction(title: TextConstants.actionSheetShareCancel, style: .cancel, handler: nil)
        controler.addAction(cancelAction)
        
        if let tempoRect = sourceRect {//if ipad
            controler.popoverPresentationController?.sourceRect = tempoRect
        }
        
        router.presentViewController(controller: controler)
    }
    
    func shareSmallSize(sourceRect: CGRect?) {
        if let items = sharingItems as? [WrapData] {
            let files: [FileForDownload] = items.flatMap({ FileForDownload(forMediumURL: $0) })
            shareFiles(filesForDownload: files, sourceRect: sourceRect)
        }
        
    }
    
    func shareOrignalSize(sourceRect: CGRect?) {
        if let items = sharingItems as? [WrapData] {
            let files: [FileForDownload] = items.flatMap({ FileForDownload(forOriginalURL: $0) })
            shareFiles(filesForDownload: files, sourceRect: sourceRect)
        }
    }
    
    private func shareFiles(filesForDownload: [FileForDownload], sourceRect: CGRect?) {
        let downloader = FilesDownloader()
        output?.operationStarted(type: .share)
        downloader.getFiles(filesForDownload: filesForDownload, response: { [weak self] fileURLs, directoryURL in
            DispatchQueue.main.async {
                self?.output?.operationFinished(type: .share)
                
                let activityVC = UIActivityViewController(activityItems: fileURLs, applicationActivities: nil)
                
                activityVC.completionWithItemsHandler = { [weak self] activityType, completed, _, _ in
                    guard let activityType = activityType else {
                        return
                    }
                    if activityType == .postToFacebook {
                        self?.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .share, eventLabel: .share(.facebook))
                    } else if activityType == .postToTwitter {
                        self?.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .share, eventLabel: .share(.twitter))
                    } else if activityType == .mail {
                        self?.analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .share, eventLabel: .share(.eMail))
                    }
                    guard
                        completed,
                        let activityTypeString = (activityType as NSString?) as String?,
                        let fileType = filesForDownload.first?.type
                        else {
                            return
                    }
                    
                    MenloworksEventsService.shared.onShareItem(with: fileType, toApp: activityTypeString.knownAppName())
                    
                    self?.analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                              eventActions: .share,
                                                              eventLabel: .shareViaApp(activityTypeString.knownAppName()))

                    do {
                        try FileManager.default.removeItem(at: directoryURL)
                    } catch {
                        print(error.description)
                    }
                }
                
                if let tempoRect = sourceRect {//if ipad
                    activityVC.popoverPresentationController?.sourceRect = tempoRect
                }
                
                self?.router.presentViewController(controller: activityVC)
            }
            }, fail: { [weak self] errorMessage in
                self?.output?.operationFailed(type: .share, message: errorMessage)
        })
    }
    
    func shareViaLink(item: [BaseDataSourceItem], sourceRect: CGRect?) {
        if (item.count == 0) {
            return
        }
        sharingItems.removeAll()
        sharingItems.append(contentsOf: item)
        
        shareViaLink(sourceRect: sourceRect)
    }
    
    func shareViaLink(sourceRect: CGRect?) {
        output?.operationStarted(type: .share)
        
        self.analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                 eventActions: .share,
                                                 eventLabel: .shareViaLink)
        
        let fileType = sharingItems.first?.fileType
        fileService.share(sharedFiles: sharingItems, success: { [weak self] url in
            DispatchQueue.main.async {
                self?.output?.operationFinished(type: .share)
                
                let objectsToShare = [url]
                let activityVC = UIActivityViewController(activityItems: objectsToShare,
                                                          applicationActivities: nil)
                activityVC.completionWithItemsHandler = { activityType, completed, _, _ in
                    guard
                        completed,
                        let activityTypeString = (activityType as NSString?) as String?,
                        let fileType = fileType
                    else {
                        return
                    }
                
                    MenloworksEventsService.shared.onShareItem(with: fileType,
                                                               toApp: activityTypeString.knownAppName())
                }
                if let tempoRect = sourceRect {//if ipad
                    activityVC.popoverPresentationController?.sourceRect = tempoRect
                }
                
                debugLog("presentViewController activityVC")
                self?.router.presentViewController(controller: activityVC)
            }
            
        }, fail: failAction(elementType: .share))
    }
    
    func info(item: [BaseDataSourceItem], isRenameMode: Bool) {
        self.output?.operationFinished(type: .info)
        
        if let infoController = router.fileInfo as? FileInfoViewController, let object = item.first {
            infoController.interactor.setObject(object: object)
            router.pushOnPresentedView(viewController: infoController)
            if isRenameMode {
                infoController.startRenaming()
            }
        }
    }
    
    
    private var cropyController: CRYCropNavigationController?
    
    func edit(item: [BaseDataSourceItem], complition: VoidHandler?) {
        
        guard let item = item.first as? Item, let url = item.metaData?.largeUrl ?? item.tmpDownloadUrl else {
            return
        }
        ImageDownloder().getImage(patch: url) { [weak self] image in
            guard
                let `self` = self,
                let image = image,
                let vc = CRYCropNavigationController.startEdit(with: image, andUseCropPage: false)
                else {
                    UIApplication.showErrorAlert(message: TextConstants.errorServer)
                    complition?()
                    return
            }
            
            //vc.setShareEnabled(true)
            //        vc.setCropDelegate(self)
            vc.sharedDelegate = self
            self.cropyController = vc
            
            complition?()
            self.router.presentViewController(controller: vc)
        }
    }
    
    func delete(item: [BaseDataSourceItem]) {
        if let items = item as? [Item] {
            deleteItems(items: items.filter({ !$0.isLocalItem }))
        } else if let albumbs = item as? [AlbumItem] {
            deleteAlbumbs(albumbs: albumbs)
        }
    }
    
    func hide(items: [BaseDataSourceItem]) {
        guard let items = items as? [Item] else {
            assertionFailure("Unexpected type of items")
            return
        }
        
        let remoteItems = items.filter { !$0.isLocalItem }
        guard !remoteItems.isEmpty else {
            assertionFailure("Locals only must not be passed to hide them")
            return
        }

        hideFunctionalityService.startHideOperation(for: remoteItems,
                                                    success: self.succesAction(elementType: .hide),
                                                    fail: self.failAction(elementType: .hide))
    }
    
    func unhide(items: [BaseDataSourceItem]) {
        let remoteItems = items.filter { !$0.isLocalItem }
        guard !remoteItems.isEmpty else {
            assertionFailure("Locals only must not be passed to hide them")
            return
        }
        
        let okHandler: PopUpButtonHandler = { vc in
            vc.close { [weak self] in
                self?.unhideItems(remoteItems)
            }
        }
        
        let popup = PopUpController.with(title: TextConstants.actionSheetUnhide,
                                         message: TextConstants.unhidePopupText,
                                         image: .unhide,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         secondAction: okHandler)
        
        router.presentViewController(controller: popup, animated: false)
    }
    
    private func unhideItems(_ items: [BaseDataSourceItem]) {
        output?.startAsyncOperationDisableScreen()
        
        var peopleItems = [PeopleItem]()
        var placesItems = [PlacesItem]()
        var thingsItems = [ThingsItem]()
        var albumItems = [AlbumItem]()
        var photosVideos = [Item]()

        items.forEach {
            if let peopleItem = $0 as? PeopleItem {
                peopleItems.append(peopleItem)
            } else if let placeItem = $0 as? PlacesItem {
                placesItems.append(placeItem)
            } else if let thingItem = $0 as? ThingsItem {
                thingsItems.append(thingItem)
            } else if let albumItem = $0 as? AlbumItem {
                albumItems.append(albumItem)
            } else if let item = $0 as? Item {
                photosVideos.append(item)
            }
        }
        
        let group = DispatchGroup()
        var error: Error?
        
        let success: FileOperation = {
            group.leave()
        }
        
        let fail: (Error) -> Void = { failError in
            group.leave()
            
            error = failError
        }
        
        if !photosVideos.isEmpty {
            group.enter()
            unhideSelectedItems(photosVideos, success: success, fail: fail)
        }
        
        if !albumItems.isEmpty {
            group.enter()
            uphideAlbums(albumItems, success: success, fail: fail)
        }
        
        if !placesItems.isEmpty {
            group.enter()
            uphideFIPAlbums(placesItems, success: success, fail: fail)
        }
        
        if !thingsItems.isEmpty {
            group.enter()
            uphideFIPAlbums(thingsItems, success: success, fail: fail)
        }
        
        if !peopleItems.isEmpty {
            group.enter()
            uphideFIPAlbums(peopleItems, success: success, fail: fail)
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            if let error = error {
                DispatchQueue.main.async {
                    self?.output?.completeAsyncOperationEnableScreen()
                    let errorResponse = ErrorResponse.error(error)
                    self?.failAction(elementType: .unhide)(errorResponse)
                }
            } else {
                DispatchQueue.main.async {
                    self?.output?.completeAsyncOperationEnableScreen()
                    self?.succesAction(elementType: .unhide)()
                }
            }
        }
    }
    
    private func unhideSelectedItems(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        hiddenService.recoverItems(items) { response in
            switch response {
            case .success(_):
                success()
                
            case .failed(let error):
                fail(error)
            }
        }
    }
    
    private func uphideAlbums(_ items: [AlbumItem], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        hiddenService.recoverAlbums(items) { response in
            switch response {
            case .success(_):
                success()
                
            case .failed(let error):
                fail(error)
            }
        }
    }
    
    //FIP - Faces-Items-Places
    private func uphideFIPAlbums(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        let responseHandler: ResponseVoid = { response in
            switch response {
            case .success(_):
                success()
                
            case .failed(let error):
                fail(error)
            }
        }
        
        if let items = items as? [PeopleItem] {
            hiddenService.recoveryPeople(items: items, handler: responseHandler)

        } else if let items = items as? [ThingsItem] {
            hiddenService.recoverItems(items, handler: responseHandler)

        } else if let items = items as? [PlacesItem] {
            hiddenService.recoveryPlaces(items: items, handler: responseHandler)

        }
    }
    
    func completelyDelete(albums: [BaseDataSourceItem]) {
        let okHandler: VoidHandler = { [weak self] in
            guard let albums = albums as? [AlbumItem] else { return }
            self?.output?.operationStarted(type: .completelyDeleteAlbums)
            let albumService = PhotosAlbumService()
            albumService.completelyDelete(albums: albums, success: { [weak self] deletedAlbums in
                DispatchQueue.main.async {
                    self?.output?.operationFinished(type: .completelyDeleteAlbums)
                    ItemOperationManager.default.albumsDeleted(albums: deletedAlbums)
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
        
        router.presentViewController(controller: controller)
    }
    
    private func deleteItems(items: [Item]) {
        RouterVC().showSpiner()
        let okHandler: VoidHandler = { [weak self] in
            self?.output?.operationStarted(type: .delete)
            self?.player.remove(listItems: items)
            self?.fileService.moveToTrash(files: items,
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
        
        router.presentViewController(controller: controller)
        router.hideSpiner()
    }
    
    private func deleteAlbumbs(albumbs: [AlbumItem]) {
        let okHandler: VoidHandler = { [weak self] in
            self?.output?.operationStarted(type: .removeFromAlbum)
            
            self?.albumService.moveToTrash(albums: albumbs, success: { [weak self] deletedAlbums in
                DispatchQueue.main.async {
                    self?.output?.operationFinished(type: .removeAlbum)
                    ItemOperationManager.default.albumsDeleted(albums: deletedAlbums)
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
        
        router.presentViewController(controller: controller)
    }
    
    private func deleteFromAlbums(items: [BaseDataSourceItem]) {
        let okHandler: VoidHandler = { [weak self] in
            guard let album = self?.router.getParentUUID(),
                let items = items as? [Item] else {
                    return
            }
            
            self?.output?.operationStarted(type: .removeFromAlbum)
            
            let parameters = DeletePhotosFromAlbum(albumUUID: album, photos: items)
            PhotosAlbumService().deletePhotosFromAlbum(parameters: parameters, success: { [weak self] in
                ItemOperationManager.default.filesRomovedFromAlbum(items: items, albumUUID: album)
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
        
        router.presentViewController(controller: controller)
    }
    
    func move(item: [BaseDataSourceItem], toPath: String) {
        guard let item = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        let itemsFolders = item.flatMap { $0.parent }
        let folderSelector = selectFolderController()
        
        folderSelector.selectFolder(select: { [weak self] folder in
            if itemsFolders.contains(folder) ||
                //case when moving file from main folder to main folder
                itemsFolders.isEmpty && folder.isEmpty{
                folderSelector.dismiss(animated: true, completion: {
                    self?.output?.showWrongFolderPopup()
                })
                return
            }
            
            self?.output?.operationStarted(type: .move)
            self?.fileService.move(items: item, toPath: folder,
                                   success: { [weak self] in
                                    self?.succesAction(elementType: .move)()
                                    //because we have animation of dismiss for this stack of view controllers we have some troubles with reloading data in root collection view
                                    //data will be updated after 0.3 seconds (time of aimation)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                        ItemOperationManager.default.filesMoved(items: item, toFolder: folder)
                                    })
                                    
                }, fail: self?.failAction(elementType: .move))
            
            }, cancel: { [weak self] in
                self?.succesAction(elementType: ElementTypes.move)()
        })
    }
    
    func copy(item: [BaseDataSourceItem], toPath: String) {
        guard let item = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        let folderSelector = selectFolderController()
        
        folderSelector.selectFolder(select: { [weak self] folder in
            self?.fileService.move(items: item, toPath: folder,
                                   success: self?.succesAction(elementType: .copy),
                                   fail: self?.failAction(elementType: .copy))
            }, cancel: { [weak self] in
                self?.succesAction(elementType: ElementTypes.move)()
        })
    }
    
    private func selectFolderController() -> SelectFolderViewController {
        if let tabBarVC = UIApplication.topController() as? TabBarViewController,
            let currentVC = tabBarVC.currentViewController as? BaseFilesGreedViewController {
            return router.selectFolder(folder: nil, sortRule: currentVC.getCurrentSortRule())
        } else {
            return router.selectFolder(folder: nil)
        }
    }
    
    func sync(item: [BaseDataSourceItem]) {
        guard let items = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        
        ///logic is appliable for a ONE syncing item only
        if let firstItem = items.first, router.getViewControllerForPresent() is PhotoVideoDetailViewController {
            
            let hideHUD = {
                DispatchQueue.toMain {
                    self.output?.completeAsyncOperationEnableScreen()
                }
            }
            
            fileService.cancellableUpload(items: [firstItem], toPath: "",
                                          success: { [weak self] in
                                            hideHUD()
                                            self?.succesAction(elementType: .sync)()
                                        }, fail: { [weak self] response in
                                            hideHUD()
                                            let handler = self?.failAction(elementType: .sync)
                                            handler?(response)
                                        }, returnedUploadOperations: { [weak self] (operations) in
                                            guard let operations = operations, !operations.isEmpty else {
                                                return
                                            }
                                            self?.output?.startCancelableAsync(with: TextConstants.uploading, cancel: {
                                                UploadService.default.cancelUploadOperations(operations: operations)
                                                ItemOperationManager.default.cancelledUpload(file: firstItem)
                                            })
                                        })
        } else {
            fileService.upload(items: items, toPath: "",
                               success: succesAction(elementType: .sync),
                               fail: failAction(elementType: .sync))
        }
    }
    
    func download(item: [BaseDataSourceItem]) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            showAccessAlert()
            return
        }
        if let item = item as? [Item] {
            //FIXME: transform all to BaseDataSourceItem
            if let item = item.first, item.fileType.isFaceImageAlbum || item.fileType.isFaceImageType {
                downloadFaceImageAlbum(item: item)
            } else {
                fileService.download(items: item, toPath: "",
                                     success: succesAction(elementType: .download),
                                     fail: failAction(elementType: .download))
            }
        } else if let albums = item as? [AlbumItem] {
            output?.startAsyncOperationDisableScreen()
            photosAlbumService.loadItemsBy(albums: albums, success: {[weak self] itemsByAlbums in
                self?.output?.completeAsyncOperationEnableScreen()
                self?.fileService.download(itemsByAlbums: itemsByAlbums,
                                           success: self?.succesAction(elementType: .download),
                                           fail: self?.failAction(elementType: .download))
            })
        }
    }
    
    func createStory(items: [BaseDataSourceItem]) {
        sync(items: items, action: {
            DispatchQueue.main.async {
                guard let items = items as? [Item] else {
                    let error = CustomErrors.text("An error has occured while images converting.")
                    UIApplication.showErrorAlert(message: error.localizedDescription)
                    return
                }
                
                let router = RouterVC()
                let controller = router.createStory(items: items)
                router.pushViewController(viewController: controller)
            }
            }, cancel: {}, fail: { errorResponse in
                UIApplication.showErrorAlert(message: errorResponse.description)
        })
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
                                        success: succesAction(elementType: .removeFromFavorites),
                                        fail: failAction(elementType: .removeFromFavorites))
    }
    
    
    // Photo Action
    
    func addToAlbum(items: [BaseDataSourceItem]) {
        sync(items: items, action: { [weak self] in
            if let vc = self?.router.addPhotosToAlbum(photos: items) {
                DispatchQueue.main.async {
                    self?.router.pushOnPresentedView(viewController: vc)
                }
            }
            }, cancel: {}, fail: { errorResponse in
                UIApplication.showErrorAlert(message: errorResponse.description)
        })
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
        let albumDetailVC = router.fileInfo as? FileInfoViewController
        albumDetailVC?.needToShowTabBar = false
        albumDetailVC?.interactor.setObject(object: items.first!)
        router.pushViewController(viewController: albumDetailVC!)
    }
    
    func downloadToCmeraRoll(items: [BaseDataSourceItem]) {
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            showAccessAlert()
            return
        }
        download(item: items)
    }
    
    private func showAccessAlert() {
        debugLog("CameraService showAccessAlert")
        DispatchQueue.main.async {
            let controller = PopUpController.with(title: TextConstants.cameraAccessAlertTitle,
                                                  message: TextConstants.cameraAccessAlertText,
                                                  image: .none,
                                                  firstButtonTitle: TextConstants.cameraAccessAlertNo,
                                                  secondButtonTitle: TextConstants.cameraAccessAlertGoToSettings,
                                                  secondAction: { vc in
                                                    vc.close {
                                                        UIApplication.shared.openSettings()
                                                    }
            })
            UIApplication.topController()?.present(controller, animated: false, completion: nil)
        } 
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
            self?.trackSuccessEvent(elementType: elementType)
            DispatchQueue.main.async {
                self?.output?.operationFinished(type: elementType)
                self?.showSuccessPopup(for: elementType)
            }
        }
        return success
    }
    
    private func showSuccessPopup(for elementType: ElementTypes) {
        let text: String
        switch elementType {
        case .download:
            text = TextConstants.popUpDownloadComplete
        case .delete:
            text = TextConstants.popUpDeleteComplete
            MenloworksAppEvents.onFileDeleted()
        case .unhide:
            text = TextConstants.unhidePopupSuccessText
        default:
            return
        }
        UIApplication.showSuccessAlert(message: text)
    }
    
    private func trackSuccessEvent(elementType: ElementTypes) {
        switch elementType {
        case .addToFavorites:
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .favoriteLike(.favorite))
        case .removeFromFavorites:
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .removefavorites)
        case .delete, .deleteDeviceOriginal, .deleteFaceImage:
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .delete)
        case .print:
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .print)
        default:
            break
        }
    }
    
    func failAction(elementType: ElementTypes) -> FailResponse {
        
        let failResponse: FailResponse  = { [weak self] value in
            DispatchQueue.toMain {
                if value.isOutOfSpaceError {
                    debugLog("failAction 1 isOutOfSpaceError")
                    if self?.router.getViewControllerForPresent() is PhotoVideoDetailViewController {
                        debugLog("failAction 2 showOutOfSpaceAlert")
                        self?.output?.showOutOfSpaceAlert(failedType: elementType)
                    }
                } else {
                    debugLog("failAction 3 \(value.description)")
                    self?.output?.operationFailed(type: elementType, message: value.description)
                }
            }
        }
        return failResponse
    }
    
    private func sync(items: [BaseDataSourceItem]?, action: @escaping VoidHandler, cancel: @escaping VoidHandler, fail: FailResponse?) {
        
        guard let items = items as? [WrapData] else {
            assertionFailure()
            return
        }
        
        let successClosure = { [weak self] in
            debugLog("SyncToUse - Success closure")
            DispatchQueue.main.async {
                self?.output?.completeAsyncOperationEnableScreen()
                action()
            }
        }
        
        let failClosure: FailResponse = { [weak self] errorResponse in
            debugLog("SyncToUse - Fail closure")
            DispatchQueue.main.async {
                self?.output?.completeAsyncOperationEnableScreen()
                if errorResponse.errorDescription == TextConstants.canceledOperationTextError {
                    cancel()
                    return
                }
                fail?(errorResponse)
            }
        }
        fileService.syncItemsIfNeeded(items, success: successClosure, fail: failClosure, syncOperations: {[weak self] syncOperations in
            let operations = syncOperations
            if operations != nil {
                self?.output?.startCancelableAsync {
                    UploadService.default.cancelSyncToUseOperations()
                    cancel()
                }
            } else {
                debugLog("syncItemsIfNeeded count: \(operations?.count ?? -1)")
            }
        })
        
    }
    
    private func downloadFaceImageAlbum(item: Item) {
        if item.fileType == .faceImage(.people),
            let id = item.id {
            peopleService.getPeopleAlbum(id: Int(id), success: { [weak self] album in
                let albumItem = AlbumItem(remote: album)
                self?.photosAlbumService.loadItemsBy(albums: [albumItem], success: {[weak self] itemsByAlbums in
                    self?.fileService.download(itemsByAlbums: itemsByAlbums,
                                               success: self?.succesAction(elementType: .download),
                                               fail: self?.failAction(elementType: .download))
                })
                }, fail: { fail in
                    UIApplication.showErrorAlert(message: fail.description)
            })
        } else if item.fileType == .faceImageAlbum(.things),
            let id = item.id {
            thingsService.getThingsAlbum(id: Int(id), success: { [weak self] album in
                let albumItem = AlbumItem(remote: album)
                
                self?.photosAlbumService.loadItemsBy(albums: [albumItem], success: {[weak self] itemsByAlbums in
                    self?.fileService.download(itemsByAlbums: itemsByAlbums,
                                               success: self?.succesAction(elementType: .download),
                                               fail: self?.failAction(elementType: .download))
                })
                }, fail: { fail in
                    UIApplication.showErrorAlert(message: fail.description)
            })
        } else if item.fileType == .faceImage(.places),
            let id = item.id {
            placesService.getPlacesAlbum(id: Int(id), success: { [ weak self] album in
                let albumItem = AlbumItem(remote: album)
                
                self?.photosAlbumService.loadItemsBy(albums: [albumItem], success: {[weak self] itemsByAlbums in
                    self?.fileService.download(itemsByAlbums: itemsByAlbums,
                                               success: self?.succesAction(elementType: .download),
                                               fail: self?.failAction(elementType: .download))
                })
                }, fail: { fail in
                    UIApplication.showErrorAlert(message: fail.description)
            })
        }
    }
    
    func trackEvent(elementType: ElementTypes) {
        switch elementType {
        case .print:
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .print)
        default:
            break
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
        MenloworksTagsService.shared.editedPhotoSaved()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
