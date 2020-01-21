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
    private let albumService = PhotosAlbumService()
    private let peopleService = PeopleService()
    private let thingsService = ThingsService()
    private let placesService = PlacesService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var hiddenService = HiddenService()

    private lazy var hideFunctionalityService: HideFuncServiceProtocol = HideSmashCoordinator()
    private lazy var smashService: SmashServiceProtocol = HideSmashCoordinator()

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
            let files: [FileForDownload] = items.compactMap { FileForDownload(forMediumURL: $0) }
            shareFiles(filesForDownload: files, sourceRect: sourceRect, shareType: .smallSize)
        }
        
    }
    
    func shareOrignalSize(sourceRect: CGRect?) {
        if let items = sharingItems as? [WrapData] {
            let files: [FileForDownload] = items.compactMap { FileForDownload(forOriginalURL: $0) }
            shareFiles(filesForDownload: files, sourceRect: sourceRect, shareType: .originalSize)
        }
    }
    
    private func shareFiles(filesForDownload: [FileForDownload], sourceRect: CGRect?, shareType: NetmeraEventValues.ShareMethodType) {
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
                    
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Share(method: shareType, channelType: activityTypeString.knownAppName()))
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
                    
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Share(method: .link, channelType: activityTypeString.knownAppName()))
                
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
        
        guard let item = item.first, let infoController = router.fileInfo(item: item) as? FileInfoViewController else {
            return
        }
        
        router.pushOnPresentedView(viewController: infoController)
        if isRenameMode {
            infoController.startRenaming()
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
                    AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Edit(status: .failure))
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
    
    func smash(item: [BaseDataSourceItem], completion: VoidHandler?) {
        guard let item = item.first as? Item, let url = item.metaData?.largeUrl ?? item.tmpDownloadUrl else {
            return
        }
        ImageDownloder().getImage(patch: url) { [weak self] image in
            guard let self = self, let image = image else {
                UIApplication.showErrorAlert(message: TextConstants.errorServer)
                completion?()
                return
            }
            
            let controller = OverlayStickerViewController()
            controller.selectedImage = image
            controller.imageName = item.name
            controller.smashCoordinator = self.smashService
            let navVC = NavigationController(rootViewController: controller)
            
            completion?()
            self.router.presentViewController(controller: navVC)
            self.trackEvent(elementType: .smash)
        }
    }
    
    func moveToTrash(item: [BaseDataSourceItem]) {
        if let items = item as? [Item] {
            moveToTrashItems(items: items.filter({ !$0.isLocalItem }))
        } else if let albums = item as? [AlbumItem] {
            moveToTrashAlbums(albums: albums)
        }
    }
    
    func hide(items: [BaseDataSourceItem]) {
        let remoteItems = items.filter { !$0.isLocalItem }
        guard !remoteItems.isEmpty else {
            assertionFailure("Locals only must not be passed to hide them")
            return
        }
        
        if let albumItems = items as? [AlbumItem] {
            hideAlbums(items: albumItems)
        } else if let items = remoteItems as? [Item] {
            hideFunctionalityService.startHideOperation(for: items,
                                                        output: self.output,
                                                        success: self.successItmesAction(elementType: .hide, relatedItems: items),
                                                        fail: self.failItmesAction(elementType: .hide, relatedItems: items))
        } else {
            assertionFailure("Unexpected type of items")
        }
    }
    
    private func hideAlbums(items: [BaseDataSourceItem]) {
           guard let items = items as? [AlbumItem] else {
               assertionFailure("Unexpected type of items")
               return
           }
           
           let remoteItems = items.filter { !$0.isLocalItem }
           guard !remoteItems.isEmpty else {
               assertionFailure("Locals only must not be passed to hide them")
               return
           }
           
        hideFunctionalityService.startHideAlbumsOperation(for: remoteItems,
                                                          output: self.output,
                                                          success: self.successItmesAction(elementType: .hide, relatedItems: items),
                                                          fail: self.failItmesAction(elementType: .hide, relatedItems: items))
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
    
    func restore(items: [BaseDataSourceItem]) {
        let remoteItems = items.filter { !$0.isLocalItem }
        guard !remoteItems.isEmpty else {
            assertionFailure("Locals only must not be passed to hide them")
            return
        }

        let okHandler: VoidHandler = { [weak self] in
            self?.output?.operationStarted(type: .restore)
            self?.putBackItems(remoteItems)
        }
        
        let controller = PopUpController.with(title: TextConstants.restoreConfirmationPopupTitle,
                                              message: TextConstants.restoreConfirmationPopupText,
                                              image: .restore,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              secondAction: { vc in
                                                vc.close(completion: okHandler)
        })
        
        router.presentViewController(controller: controller)
        router.hideSpiner()
    }
    
    private func removeAlbumItems(_ items: [BaseDataSourceItem]) {
        let okHandler: VoidHandler = { [weak self] in
            guard let album = self?.router.getParentUUID(), let items = items as? [Item] else {
                return
            }
            
            self?.output?.operationStarted(type: .removeFromAlbum)
            
            let parameters = DeletePhotosFromAlbum(albumUUID: album, photos: items)
            self?.albumService.deletePhotosFromAlbum(parameters: parameters, success: { [weak self] in
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
            
            if let firstItem = item.first {
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Download(type: firstItem.fileType, count: item.count))
            }
            
            //FIXME: transform all to BaseDataSourceItem
            if let item = item.first, item.fileType.isFaceImageAlbum || item.fileType.isFaceImageType {
                downloadFaceImageAlbum(item: item)
            } else {
                fileService.download(items: item, toPath: "",
                                     success: succesAction(elementType: .download),
                                     fail: failAction(elementType: .download))
            }
        } else if let albums = item as? [AlbumItem] {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Download(type: .album, count: albums.count))
            output?.startAsyncOperationDisableScreen()
            albumService.loadItemsBy(albums: albums, success: {[weak self] itemsByAlbums in
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
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AddToAlbum(status: .failure))
                UIApplication.showErrorAlert(message: errorResponse.description)
        })
    }
    
    func backUp(items: [BaseDataSourceItem]) {
        
    }
    
    func removeFromAlbum(items: [BaseDataSourceItem]) {
        removeAlbumItems(items)
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
        guard let album = items.first, let albumDetailVC = router.fileInfo(item: album) as? FileInfoViewController else {
            return
        }
        
        albumDetailVC.needToShowTabBar = false
        router.pushViewController(viewController: albumDetailVC)
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
    
    func delete(items: [BaseDataSourceItem]) {
        let okHandler: PopUpButtonHandler = { vc in
            vc.close { [weak self] in
                self?.deleteItems(items)
            }
        }
        
        let popup = PopUpController.with(title: TextConstants.deleteConfirmationPopupTitle,
                                         message: TextConstants.deleteConfirmationPopupText,
                                         image: .delete,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         secondAction: okHandler)
        
        router.presentViewController(controller: popup, animated: false)
    }
    
    func deleteDeviceOriginal(items: [BaseDataSourceItem]) {
        guard let wrapedItems = items as? [WrapData] else {
            return
        }
        fileService.deleteLocalFiles(deleteFiles: wrapedItems, success: succesAction(elementType: .deleteDeviceOriginal),
                                     fail: failAction(elementType: .deleteDeviceOriginal))
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
            peopleService.getPeopleAlbum(id: Int(id), status: .active, success: { [weak self] album in
                let albumItem = AlbumItem(remote: album)
                self?.albumService.loadItemsBy(albums: [albumItem], success: {[weak self] itemsByAlbums in
                    self?.fileService.download(itemsByAlbums: itemsByAlbums,
                                               success: self?.succesAction(elementType: .download),
                                               fail: self?.failAction(elementType: .download))
                })
                }, fail: { fail in
                    UIApplication.showErrorAlert(message: fail.description)
            })
        } else if item.fileType == .faceImageAlbum(.things),
            let id = item.id {
            thingsService.getThingsAlbum(id: Int(id), status: .active, success: { [weak self] album in
                let albumItem = AlbumItem(remote: album)
                
                self?.albumService.loadItemsBy(albums: [albumItem], success: {[weak self] itemsByAlbums in
                    self?.fileService.download(itemsByAlbums: itemsByAlbums,
                                               success: self?.succesAction(elementType: .download),
                                               fail: self?.failAction(elementType: .download))
                })
                }, fail: { fail in
                    UIApplication.showErrorAlert(message: fail.description)
            })
        } else if item.fileType == .faceImage(.places),
            let id = item.id {
            placesService.getPlacesAlbum(id: Int(id), status: .active, success: { [ weak self] album in
                let albumItem = AlbumItem(remote: album)
                
                self?.albumService.loadItemsBy(albums: [albumItem], success: {[weak self] itemsByAlbums in
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
        case .smash:
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .smash)
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
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Edit(status: .success))
        MenloworksTagsService.shared.editedPhotoSaved()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

//MARK: - Actions

extension MoreFilesActionsInteractor {
    
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
    
    func successItmesAction(elementType: ElementTypes, relatedItems: [BaseDataSourceItem]) -> FileOperation {
        let success: FileOperation = { [weak self] in
            self?.trackSuccessEvent(elementType: elementType)
            self?.trackNetmeraSuccessEvent(elementType: elementType, successStatus: .success, items: relatedItems)
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
        case .moveToTrash:
            text = TextConstants.popUpDeleteComplete
        case .unhide:
            text = TextConstants.unhidePopupSuccessText
        case .delete:
            text = TextConstants.deletePopupSuccessText
            MenloworksAppEvents.onFileDeleted()
        case .restore:
            text = TextConstants.restorePopupSuccessText
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
        case .delete, .deleteDeviceOriginal:
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .delete)
        case .print:
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .print)
        default:
            break
        }
    }
    
    private func trackNetmeraSuccessEvent(elementType: ElementTypes, successStatus: NetmeraEventValues.GeneralStatus, items: [BaseDataSourceItem]) {
        //TODO: change other parts of actions tracking to this method
        switch elementType {
        case .moveToTrash:
            NetmeraService.getItemsTypeToCount(items: items).forEach { typeToCountTupple in
                guard typeToCountTupple.1 > 0, let event = NetmeraEvents.Actions.Trash(status: successStatus, typeCountTupple: typeToCountTupple) else {
                    return
                }
                AnalyticsService.sendNetmeraEvent(event: event)
            }
        case .hide:
            NetmeraService.getItemsTypeToCount(items: items).forEach { typeToCountTupple in
                guard typeToCountTupple.1 > 0, let event = NetmeraEvents.Actions.Hide(status: successStatus, typeCountTupple: typeToCountTupple) else {
                    return
                }
                AnalyticsService.sendNetmeraEvent(event: event)
            }
        case .unhide:
            NetmeraService.getItemsTypeToCount(items: items).forEach { typeToCountTupple in
                guard typeToCountTupple.1 > 0, let event = NetmeraEvents.Actions.Unhide(status: successStatus, typeCountTupple: typeToCountTupple) else {
                    return
                }
                AnalyticsService.sendNetmeraEvent(event: event)
            }
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
    
    func failItmesAction(elementType: ElementTypes, relatedItems: [BaseDataSourceItem]) -> FailResponse {
        
        let failResponse: FailResponse  = { [weak self] value in
            self?.trackNetmeraSuccessEvent(elementType: elementType, successStatus: .failure, items: relatedItems)
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
}

//MARK: - Divorce
extension MoreFilesActionsInteractor {
    typealias DivorceItemsOperation = (
        _ items: [Item],
        _ success: @escaping FileOperation,
        _ fail: @escaping ((Error) -> Void)
    ) -> ()
    
    typealias DivorceAlbumsOperation = (
        _ albums: [AlbumItem],
        _ success: @escaping FileOperation,
        _ fail: @escaping ((Error) -> Void)
    ) -> ()

    private func divorceItems(
        type: ElementTypes,
        items: [BaseDataSourceItem],
        itemsOperation: @escaping DivorceItemsOperation,
        albumsOperation: @escaping DivorceAlbumsOperation,
        firOperation: @escaping DivorceItemsOperation)
    {
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
            itemsOperation(photosVideos, success, fail)
        }
        
        if !albumItems.isEmpty {
            group.enter()
            albumsOperation(albumItems, success, fail)
        }
        
        if !placesItems.isEmpty {
            group.enter()
            firOperation(placesItems, success, fail)
        }
        
        if !thingsItems.isEmpty {
            group.enter()
            firOperation(thingsItems, success, fail)
        }
        
        if !peopleItems.isEmpty {
            group.enter()
            firOperation(peopleItems, success, fail)
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.output?.completeAsyncOperationEnableScreen()
            if let error = error {
                let errorResponse = ErrorResponse.error(error)
                self?.failAction(elementType: type)(errorResponse)
            } else {
                self?.succesAction(elementType: type)()
            }
        }
    }
}

//MARK: - UNHIDE
extension MoreFilesActionsInteractor {
    private func unhideItems(_ items: [BaseDataSourceItem]) {
        divorceItems(type: .unhide,
                     items: items,
                     itemsOperation:
            { [weak self] items, success, fail in
                        self?.unhideSelectedItems(items, success: success, fail: fail)
            },
                     
                     albumsOperation:
            { [weak self] items, success, fail in
                        self?.unhideAlbums(items, success: success, fail: fail)
            },
                     
                     firOperation:
            { [weak self] items, success, fail in
                        self?.unhideFIRAlbums(items, success: success, fail: fail)
            })
    }
    
    private func unhideSelectedItems(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        fileService.unhide(items: items, success: success, fail: fail)
    }
    
    private func unhideAlbums(_ items: [AlbumItem], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        fileService.unhideAlbums(items, success: success, fail: fail)
    }
    
    private func unhideFIRAlbums(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        if let items = items as? [PeopleItem] {
            fileService.unhidePeople(items: items, success: success, fail: fail)

        } else if let items = items as? [ThingsItem] {
            fileService.unhideThings(items: items, success: success, fail: fail)

        } else if let items = items as? [PlacesItem] {
            fileService.unhidePlaces(items: items, success: success, fail: fail)

        }
    }
}

//MARK: - MOVETOTRASH
extension MoreFilesActionsInteractor {
    private func moveToTrashItems(items: [Item]) {
        guard !items.isEmpty else {
            return
        }
//        elementType: .moveToTrash, relatedItems: items
        RouterVC().showSpiner()
        let okHandler: VoidHandler = { [weak self] in
            self?.output?.operationStarted(type: .moveToTrash)
            self?.player.remove(listItems: items)
            self?.fileService.moveToTrash(files: items,
                                          success: self?.successItmesAction(elementType: .moveToTrash, relatedItems: items),
                                          fail: self?.failItmesAction(elementType: .moveToTrash, relatedItems: items))
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
    
    private func moveToTrashAlbums(albums: [AlbumItem]) {
        let okHandler: VoidHandler = { [weak self] in
            self?.output?.operationStarted(type: .moveToTrash)
            
            self?.albumService.moveToTrash(albums: albums, success: { [weak self] deletedAlbums in
                self?.trackNetmeraSuccessEvent(elementType: .moveToTrash, successStatus: .success, items: deletedAlbums)

                DispatchQueue.main.async {
                    self?.output?.operationFinished(type: .moveToTrash)
                    ItemOperationManager.default.didMoveToTrashAlbums(albums)
                    
                    let controller = PopUpController.with(title: TextConstants.success,
                                                          message: TextConstants.moveToTrashAlbumsSuccess,
                                                          image: .success,
                                                          buttonTitle: TextConstants.ok)
                    self?.router.presentViewController(controller: controller)
                }
                }, fail: { [weak self] errorRespone in
                    self?.trackNetmeraSuccessEvent(elementType: .moveToTrash, successStatus: .failure, items: albums)
                    DispatchQueue.main.async {
                        self?.output?.operationFailed(type: .moveToTrash, message: errorRespone.description)
                    }
            })
        }
        //TextConstants.actionSheetDelete
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
}

//MARK: - DELETE
extension MoreFilesActionsInteractor {
    private func deleteItems(_ items: [BaseDataSourceItem]) {
        divorceItems(type: .delete,
                     items: items,
                     itemsOperation:
            { [weak self] items, success, fail in
                        self?.deleteSelectedItems(items, success: success, fail: fail)
            },
                     
                     albumsOperation:
            { [weak self] items, success, fail in
                        self?.deleteAlbums(items, success: success, fail: fail)
            },
                     
                     firOperation:
            { [weak self] items, success, fail in
                        self?.deleteFIRAlbums(items, success: success, fail: fail)
            })
    }
    
    private func deleteSelectedItems(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        player.remove(listItems: items)
        fileService.delete(items: items, success: success, fail: fail)
    }
    
    private func deleteAlbums(_ items: [AlbumItem], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        albumService.completelyDelete(albums: items, success: { _ in
            success()
        }, fail: { errorResponse in
            fail(errorResponse)
        })
    }
    
    private func deleteFIRAlbums(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        if let items = items as? [PeopleItem] {
            fileService.deletePeople(items: items, success: success, fail: fail)

        } else if let items = items as? [ThingsItem] {
            fileService.deleteThings(items: items, success: success, fail: fail)

        } else if let items = items as? [PlacesItem] {
            fileService.deletePlaces(items: items, success: success, fail: fail)

        }
    }
}

//MARK: - RESTORE
extension MoreFilesActionsInteractor {
    private func putBackItems(_ items: [BaseDataSourceItem]) {
        divorceItems(type: .restore,
                     items: items,
                     itemsOperation:
            { [weak self] items, success, fail in
                        self?.putBackSelectedItems(items, success: success, fail: fail)
            },
                     
                     albumsOperation:
            { [weak self] items, success, fail in
                        self?.putBackAlbums(items, success: success, fail: fail)
            },
                     
                     firOperation:
            { [weak self] items, success, fail in
                        self?.putBackFIRAlbums(items, success: success, fail: fail)
            })
    }
    
    private func putBackSelectedItems(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        player.remove(listItems: items)
        fileService.putBack(items: items, success: success, fail: fail)
    }
    
    private func putBackAlbums(_ items: [AlbumItem], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        fileService.putBackAlbums(items, success: success, fail: fail)
    }
    
    private func putBackFIRAlbums(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        if let items = items as? [PeopleItem] {
            fileService.putBackPeople(items: items, success: success, fail: fail)

        } else if let items = items as? [ThingsItem] {
            fileService.putBackThings(items: items, success: success, fail: fail)

        } else if let items = items as? [PlacesItem] {
            fileService.putBackPlaces(items: items, success: success, fail: fail)

        }
    }
}
