//
//  MoreFilesActionsInteractor.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import WidgetKit
import FirebaseDynamicLinks

enum DivorseItems {
    case items
    case albums
    case folders
}

enum ShareTypes {
    case original
    case link
    case `private`
    
    var actionTitle: String {
        switch self {
        case .original:
            return TextConstants.actionSheetShareOriginalSize
        case .link:
            return TextConstants.actionSheetShareShareViaLink
        case .private:
            return TextConstants.actionSheetSharePrivate
        }
    }
    
    static func allowedTypes(for items: [BaseDataSourceItem]) -> [ShareTypes] {
        var allowedTypes = [ShareTypes]()
        
        if items.contains(where: { $0.fileType == .folder}) {
            allowedTypes = [.link, .private]
        } else if items.contains(where: { return $0.fileType != .image && $0.fileType != .video && !$0.fileType.isDocumentPageItem && $0.fileType != .audio}) {
            allowedTypes = [.link]
        } else {
            allowedTypes = [.original, .link, .private]
        }
        
        if items.count > NumericConstants.numberOfSelectedItemsBeforeLimits {
            allowedTypes.remove(.original)
        }
        
        if items.contains(where: { $0.isLocalItem }) {
            allowedTypes.remove(.private)
        }
        
        return allowedTypes
    }
}

class MoreFilesActionsInteractor: NSObject, MoreFilesActionsInteractorInput {
    
    weak var output: MoreFilesActionsInteractorOutput?
    
    lazy var player: MediaPlayer = factory.resolve()
    
    let router = RouterVC()
    
    private var fileService = WrapItemFileService()
    private let albumService = PhotosAlbumService()
    private let peopleService = PeopleService()
    private let thingsService = ThingsService()
    private let placesService = PlacesService()
    
    private lazy var hiddenService = HiddenService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var hideActionService: HideActionServiceProtocol = HideActionService()
    private lazy var smashActionService: SmashActionServiceProtocol = SmashActionService()
    private lazy var photoEditImageDownloader = PhotoEditImageDownloader()
    private lazy var privateShareAnalytics = PrivateShareAnalytics()
    private lazy var onlyOfficeService = OnlyOfficeService()
    
    typealias FailResponse = (_ value: ErrorResponse) -> Void
    
    var sharingItems = [BaseDataSourceItem]()
    
    func share(item: [BaseDataSourceItem], sourceRect: CGRect?) {
        guard !item.isEmpty else {
            return
        }
        
        sharingItems.removeAll()
        sharingItems.append(contentsOf: item)
        
        selectShareType(sourceRect: sourceRect)
    }
    
    func selectShareType(sourceRect: CGRect?) {
        let sharedTypes = ShareTypes.allowedTypes(for: sharingItems)
        showSharingMenu(types: sharedTypes, sourceRect: sourceRect)
    }
    
    private func showSharingMenu(types: [ShareTypes], sourceRect: CGRect?) {
        let controler = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controler.view.tintColor = AppColor.marineTwoAndWhite.color
        
        types.forEach {
            controler.addAction(getAction(shareType: $0, sourceRect: sourceRect))
        }
        
        let cancelAction = UIAlertAction(title: TextConstants.actionSheetShareCancel, style: .cancel, handler: nil)
        controler.addAction(cancelAction)
        
        if let tempoRect = sourceRect {//if ipad
            controler.popoverPresentationController?.sourceRect = tempoRect
        }
        
        router.presentViewController(controller: controler)
    }
    
    private func getAction(shareType: ShareTypes, sourceRect: CGRect?) -> UIAlertAction {
        
        return UIAlertAction(title: shareType.actionTitle, style: .default) { [weak self] action in
            guard let self = self else {
                return
            }
            self.handleShare(type: shareType, sourceRect: sourceRect, items: self.sharingItems)
        }
    }
    
    func handleShare(type: ShareTypes, sourceRect: CGRect?, items: [BaseDataSourceItem]) {
        self.sharingItems = items
        switch type {
        case .link:
            let needSync = items.contains(where: { $0.isLocalItem })
            if needSync {
                sync(items: sharingItems, action: { [weak self] in
                    self?.shareViaLink(sourceRect: sourceRect)
                }, fail: { errorResponse in
                    debugLog("sync(items: \(errorResponse.description)")
                    UIApplication.showErrorAlert(message: errorResponse.description)
                })
            } else {
                shareViaLink(sourceRect: sourceRect)
            }
        case .original:
            sync(items: sharingItems, action: { [weak self] in
                self?.shareOrignalSize(sourceRect: sourceRect)
                }, fail: { errorResponse in
                    UIApplication.showErrorAlert(message: errorResponse.description)
            })
        case .private:
            privateShare()
        }
    }
    
    func handleShareAction(type: ElementTypes, sourceRect: CGRect?, items: [BaseDataSourceItem]) {
        guard !items.isEmpty else {
            return
        }
        
        sharingItems.removeAll()
        sharingItems.append(contentsOf: items)
        
        self.sharingItems = items
        switch type {
        case .shareLink:
            let needSync = items.contains(where: { $0.isLocalItem })
            if needSync {
                sync(items: sharingItems, action: { [weak self] in
                    self?.shareViaLink(sourceRect: sourceRect)
                }, fail: { errorResponse in
                    debugLog("sync(items: \(errorResponse.description)")
                    UIApplication.showErrorAlert(message: errorResponse.description)
                })
            } else {
                shareViaLink(sourceRect: sourceRect)
            }
        case .shareOriginal:
            sync(items: sharingItems, action: { [weak self] in
                self?.shareOrignalSize(sourceRect: sourceRect)
                }, fail: { errorResponse in
                    UIApplication.showErrorAlert(message: errorResponse.description)
            })
        case .sharePrivate:
            privateShare()
        default:
            return
        }
    }
    
    func privateShare() {
        guard let items = sharingItems as? [WrapData] else {
            return
        }
        
        privateShareAnalytics.openPrivateShare()
        
        let controller = router.privateShare(items: items)
        router.presentViewController(controller: controller)
    }
    
    func shareSmallSize(sourceRect: CGRect?) {
        if let items = sharingItems as? [WrapData] {
            let files: [FileForDownload] = items.compactMap { FileForDownload(forMediumURL: $0) }
            shareFiles(filesForDownload: files, sourceRect: sourceRect, shareType: .smallSize)
        }
        
    }
    
    func shareOrignalSize(sourceRect: CGRect?) {
        if let items = sharingItems as? [WrapData] {
            let filesWithoutUrl = items.filter { $0.tmpDownloadUrl == nil }
            fileService.createDownloadUrls(for: filesWithoutUrl) { [weak self] in
                guard let self = self else {
                    return
                }
                
                let files: [FileForDownload] = items.compactMap { FileForDownload(forOriginalURL: $0) }
                self.shareFiles(filesForDownload: files, sourceRect: sourceRect, shareType: .originalSize)
            }
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
                    guard completed, let activityTypeString = activityType?.rawValue  else {
                        return
                    }

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
        guard !item.isEmpty else {
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
        
        fileService.share(sharedFiles: sharingItems, success: { [weak self] url in
            DispatchQueue.main.async {
                guard
                    let self = self,
                    let output = self.output
                else {
                    return
                }
                output.operationFinished(type: .share)
                
                self.createDynamicLink(with: url) { dynamicLinkUrl in
                    let objectsToShare = [dynamicLinkUrl?.absoluteString ?? url]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare,
                                                              applicationActivities: nil)
                    activityVC.completionWithItemsHandler = { activityType, completed, _, _ in
                        guard completed, let activityTypeString = activityType?.rawValue else {
                            return
                        }
                        output.stopSelectionMode()
                        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Share(method: .link, channelType: activityTypeString.knownAppName()))
                    }
                    if let tempoRect = sourceRect {//if ipad
                        activityVC.popoverPresentationController?.sourceRect = tempoRect
                    }
                    
                    debugLog("presentViewController activityVC")
                    self.router.presentViewController(controller: activityVC)
                }
            }
            
        }, fail: failAction(elementType: .share))
    }
    
    func createDynamicLink(with url: String, completion: @escaping (URL?) -> ()) {
        guard let link = URL(string: url) else {
            completion(nil)
            return
        }
        
        let dynamicLinksDomainURIPrefix = RouteRequests.dynamicLinkDomain
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        
        if let bundleID = Bundle.main.bundleIdentifier {
            linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleID)
        }
        linkBuilder?.iOSParameters?.appStoreID = Device.applicationId
        linkBuilder?.iOSParameters?.fallbackURL = link

        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: Device.androidPackageName)
        linkBuilder?.androidParameters?.fallbackURL = link
        
        linkBuilder?.navigationInfoParameters = DynamicLinkNavigationInfoParameters()
        linkBuilder?.navigationInfoParameters?.isForcedRedirectEnabled = true
        linkBuilder?.otherPlatformParameters?.fallbackUrl = link

        linkBuilder?.shorten(completion: { url, warnings, error in
            if error != nil {
                debugLog("Error occured while shorting dynamic link")
                completion(linkBuilder?.url)
            }
            
            guard let url = url else { return }
            completion(url)
        })
    }
    
    func info(item: [BaseDataSourceItem], isRenameMode: Bool) {        
        guard let item = item.first, let infoController = router.fileInfo(item: item) as? FileInfoViewController else {
            return
        }
        
        if let topViewController = RouterVC().getViewControllerForPresent() as? PhotoVideoDetailViewInput, !UIDevice.current.orientation.isLandscape {
            topViewController.showBottomDetailView()
        } else {
            router.pushViewController(viewController: infoController)
        }
        
        if isRenameMode {
            infoController.startRenaming()
        }
    }
    
    func edit(item: [BaseDataSourceItem], completion: VoidHandler?) {
        debugLog("PHOTOEDIT: start")
        
        guard let item = item.first as? Item else {
            completion?()
            debugLog("PHOTOEDIT: there's no item")
            return
        }
        
        if let originalUrl = item.tmpDownloadUrl {
            downloadEditImage(item: item, url: originalUrl, completion: completion)
        } else {
            fileService.createDownloadUrls(for: [item]) { [weak self] in
                guard
                    let self = self,
                    let originalUrl = item.tmpDownloadUrl
                else {
                    completion?()
                    debugLog("PHOTOEDIT: there's no url for private")
                    return
                }
                self.downloadEditImage(item: item, url: originalUrl, completion: completion)
            }
        }
    }
    
    private func downloadEditImage(item: WrapData, url: URL, completion: VoidHandler?) {
        photoEditImageDownloader.download(url: url, attempts: 2) { [weak self] image in
            guard
                let self = self,
                let image = image
            else {
                debugLog("PHOTOEDIT: can't get the original image")
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Edit(status: .failure))
                UIApplication.showErrorAlert(message: TextConstants.errorServer)
                completion?()
                return
            }
            
           let options = [
            kCGImageSourceCreateThumbnailWithTransform: false,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 1024] as CFDictionary
            
            guard
                let previewData = image.jpeg(.low),
                let source = CGImageSourceCreateWithData(previewData as CFData, options),
                let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)
            else {
                debugLog("PHOTOEDIT: can't create the preview image")
                UIApplication.showErrorAlert(message: TextConstants.commonServiceError)
                completion?()
                return
            }
            
            let previewImage = UIImage(cgImage: imageReference, scale: image.scale, orientation: image.imageOrientation)

            debugLog("PHOTOEDIT: is about to create the controller")

            let vc = PhotoEditViewController.with(originalImage: image.imageWithFixedOrientation, previewImage: previewImage.imageWithFixedOrientation, presented: completion) { [weak self] controller, completionType in

                switch completionType {
                case .canceled:
                    controller.dismiss(animated: true)
                    
                case .savedAs(image: let newImage):
                    controller.showSpinner()

                    PhotoEditSaveService.shared.save(asCopy: true, image: newImage, item: item) { [weak self] result in
                        switch result {
                        case .success(let remote):
                            DispatchQueue.main.async {
                                controller.saveImageComplete(saveAsCopy: true)
                                controller.dismiss(animated: false) {
                                    self?.showPhotoVideoPreview(item: remote) {
                                        SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.photoEditSaveAsCopySnackbarMessage)
                                    }
                                }
                            }

                        case .failed(_):
                            DispatchQueue.main.async {
                                controller.saveImageFailure(saveAsCopy: true)
                                controller.hideSpinner()
                                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.photoEditSaveImageErrorMessage)
                            }
                        }
                    }

                case .savedAsWithStickers(let stickerImageView):
                    guard let (originalImage, attachments) = stickerImageView.getCondition() else {
                        assertionFailure()
                        return
                    }

                    controller.showSpinner()
                    PhotoEditSaveService.shared.saveWithStickers(
                        originalImage: originalImage,
                        attachments: attachments,
                        stickerImageView: stickerImageView,
                        item: item) { [weak self] result in

                        switch result {
                        case .success(let remote):
                            DispatchQueue.main.async {
                                controller.saveImageComplete(saveAsCopy: true)
                                controller.dismiss(animated: false) {
                                    self?.showPhotoVideoPreview(item: remote) {
                                        SnackbarManager.shared.show(
                                            type: .nonCritical,
                                            message: TextConstants.photoEditSaveAsCopySnackbarMessage
                                        )
                                    }
                                }
                            }
                        case .failed:
                            DispatchQueue.main.async {
                                controller.saveImageFailure(saveAsCopy: true)
                                controller.hideSpinner()
                                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.photoEditSaveImageErrorMessage)
                            }
                        }
                    }

                    break

                case .saved(image: let newImage):
                    controller.showSpinner()

                    var newThumbnails = [UIImage]()
                    var urlsToReplace = [URL]()

                    if let smallUrl = item.metaData?.smalURl {
                        urlsToReplace.append(smallUrl)
                        newThumbnails.append(newImage.resizedImage(to: CGSize(width: 64, height: 64)))
                    }
                    if let mediumUrl = item.metaData?.mediumUrl {
                        urlsToReplace.append(mediumUrl)
                        newThumbnails.append(newImage.resizedImage(to: CGSize(width: 128, height: 128)))
                    }
                    if let largeUrl = item.metaData?.largeUrl {
                        urlsToReplace.append(largeUrl)
                        newThumbnails.append(newImage.resizedImage(to: CGSize(width: 1024, height: 1024)))
                    }
                    if case .remoteUrl(let pathUrl) = item.patchToPreview, pathUrl != nil {
                        urlsToReplace.append(pathUrl)
                        newThumbnails.append(newImage.resizedImage(to: CGSize(width: 1024, height: 1024)))
                    }


                    PhotoEditSaveService.shared.save(asCopy: false, image: newImage, item: item) { [weak self] result in
                        switch result {
                        case .success(let updatedItem):

                            item.copyFileData(from: updatedItem)
                            item.patchToPreview = updatedItem.patchToPreview

                            let closeScreen = {
                                DispatchQueue.main.async {
                                    controller.saveImageComplete(saveAsCopy: false)
                                    controller.dismiss(animated: true)
                                    SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.photoEditModifySnackbarMessage)
                                }
                            }

                            ImageDownloder.removeImageFromCache(url: updatedItem.tmpDownloadUrl, completion: {
                                ImageDownloder.replaceImagesInCache(urls: urlsToReplace, images: newThumbnails, completion: closeScreen)
                            })

                        case .failed(_):
                            DispatchQueue.main.async {
                                controller.saveImageFailure(saveAsCopy: false)
                                controller.hideSpinner()
                                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.photoEditSaveImageErrorMessage)
                            }
                        }
                    }
                }
            }
            self.router.presentViewController(controller: vc)
        }
    }
    
    private func showPhotoVideoPreview(item: WrapData, completion: @escaping VoidHandler) {
        let detailModule = router.filesDetailModule(fileObject: item,
                                                    items: [item],
                                                    status: item.status,
                                                    canLoadMoreItems: false,
                                                    moduleOutput: nil)
        
        let nController = NavigationController(rootViewController: detailModule.controller)
        router.presentViewController(controller: nController, animated: true, completion: completion)
    }

        
    func smash(item: [BaseDataSourceItem], completion: VoidHandler?) {
        guard let item = item.first as? Item, let url = item.metaData?.largeUrl ?? item.tmpDownloadUrl else {
            completion?()
            return
        }
        
        let controller = OverlayStickerViewController()
        controller.smashActionService = self.smashActionService
        let navVC = NavigationController(rootViewController: controller)
        navVC.navigationBar.isHidden = true
        router.presentViewController(controller: navVC, animated: true) { [weak self] in
            ImageDownloder().getImage(patch: url) { [weak self] image in
                guard
                    let self = self,
                    let image = image
                else {
                    if !ReachabilityService.shared.isReachable {
                        controller.dismiss(animated: false) {
                             UIApplication.showErrorAlert(message: TextConstants.errorConnectedToNetwork)
                        }
                    }
            
                    completion?()
                    return
                }
                
                controller.selectedImage = image
                controller.imageName = item.name
                completion?()
                
                self.trackEvent(elementType: .smash)
            }
        }
    }
    
    func moveToTrash(items: [BaseDataSourceItem]) {
        let cancelHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .trash, label: .cancel)
            vc.close()
        }
        
        let okHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .trash, label: .ok)
            self?.output?.operationStarted(type: .moveToTrash)
            vc.close { [weak self] in
                self?.moveToTrash(items)
            }
        }
        
        trackScreen(.fileOperationConfirmPopup(.trash))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.DeleteConfirmPopUp())
        
        let message: String
        if isAlbums(items) {
            if (items.first as? Item)?.status == .hidden {
                message = TextConstants.moveToTrashHiddenAlbumsConfirmationPopupText
            } else {
                message = TextConstants.deleteAlbums
            }
        } else {
            message = TextConstants.deleteFilesText
        }
        
        let popup = PopUpController.with(title: TextConstants.actionSheetDelete,
                                         message: message,
                                         image: .delete,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         firstAction: cancelHandler,
                                         secondAction: okHandler)
        
        popup.open()
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
            hideActionService.startOperation(for: .photos(items),
                                             output: self.output,
                                             success: self.successAction(elementType: .hide, itemsType: .items, relatedItems: items),
                                             fail: self.failAction(elementType: .hide, relatedItems: items))
            
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

        hideActionService.startOperation(for: .albums(remoteItems),
                                         output: self.output,
                                         success: self.successAction(elementType: .hide, itemsType: .albums, relatedItems: items),
                                         fail: self.failAction(elementType: .hide, relatedItems: items))
    }
    
    func unhide(items: [BaseDataSourceItem]) {
        let remoteItems = items.filter { !$0.isLocalItem }
        guard !remoteItems.isEmpty else {
            assertionFailure("Locals only must not be passed to hide them")
            return
        }
        
        let cancelHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .unhide, label: .cancel)
            vc.close()
        }
        
        let okHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .unhide, label: .ok)
            self?.output?.operationStarted(type: .unhide)
            vc.close { [weak self] in
                self?.unhideItems(remoteItems)
            }
        }
        
        trackScreen(.fileOperationConfirmPopup(.unhide))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.UnhideConfirmPopUp())
        
        let message = isAlbums(items) ? TextConstants.unhideAlbumsPopupText : TextConstants.unhideItemsPopupText
        let popup = PopUpController.with(title: TextConstants.actionSheetUnhide,
                                         message: message,
                                         image: .unhide,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         firstAction: cancelHandler,
                                         secondAction: okHandler)
        popup.open()
    
    }
    
    func restore(items: [BaseDataSourceItem], completion: @escaping VoidHandler) {
        let remoteItems = items.filter { !$0.isLocalItem }
        guard !remoteItems.isEmpty else {
            assertionFailure("Locals only must not be passed to hide them")
            return
        }
        
        let cancelHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .restore, label: .cancel)
            vc.close()
        }

        let okHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .restore, label: .ok)
            self?.output?.operationStarted(type: .restore)
            vc.close { [weak self] in
                self?.putBackItems(remoteItems)
                completion()
            }
        }
        
        trackScreen(.fileOperationConfirmPopup(.restore))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.RestoreConfirmPopUp())
        

        let message: String
        if isAlbums(items) {
            message = TextConstants.restoreAlbumsConfirmationPopupText
        } else if items.allSatisfy({ $0.fileType == .folder }) {
            message = TextConstants.restoreFoldersConfirmationPopupText
        } else {
            message = TextConstants.restoreItemsConfirmationPopupText
        }
        let controller = PopUpController.with(title: TextConstants.restoreConfirmationPopupTitle,
                                              message: message,
                                              image: .restore,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              firstAction: cancelHandler,
                                              secondAction: okHandler)
        
        controller.open()
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
                    self?.showSnackbar(elementType: .removeFromAlbum, relatedItems: [])
                    self?.output?.operationFinished(type: .removeFromAlbum)
                }
            }, fail: { [weak self] errorRespone in
                DispatchQueue.main.async {
                    self?.output?.operationFailed(type: .removeFromAlbum, message: errorRespone.description)
                }
            })
        }
        
        let controller = PopUpController.with(title: TextConstants.actionSheetRemove,
                                              message: TextConstants.removeFromAlbum,
                                              image: .delete,
                                              firstButtonTitle: TextConstants.cancel,
                                              secondButtonTitle: TextConstants.ok,
                                              secondAction: { vc in
                                                vc.close(completion: okHandler)
        })
        
        controller.open()
    }
    
    private func deletePhotosFromAlbum(items: [BaseDataSourceItem], item: Item) {
        let okHandler: VoidHandler = { [weak self] in
            guard let self = self, let items = items as? [Item], item.fileType.isFaceImageType, let id = item.id else {
                return
            }
            
            let album = self.router.getParentUUID()
            
            self.output?.operationStarted(type: .removeFromFaceImageAlbum)
            
            let successHandler: PhotosAlbumOperation = { [weak self] in
                DispatchQueue.main.async {
                    ItemOperationManager.default.filesRomovedFromAlbum(items: items, albumUUID: album)
                    self?.showSnackbar(elementType: .removeFromFaceImageAlbum, relatedItems: [])
                    self?.output?.operationFinished(type: .removeFromFaceImageAlbum)
                }
            }
            
            let failHandler: FailResponse = { [weak self] error in
                self?.output?.operationFailed(type: .removeFromFaceImageAlbum, message: error.description)
            }

            switch item.fileType {
            case .faceImage(.people):
                self.peopleService.deletePhotosFromAlbum(id: id, photos: items, success: successHandler, fail: failHandler)
            case .faceImage(.places):
                self.placesService.deletePhotosFromAlbum(uuid: album, photos: items, success: successHandler, fail: failHandler)
            case .faceImage(.things):
                self.thingsService.deletePhotosFromAlbum(id: id, photos: items, success: successHandler, fail: failHandler)
            default:
                break
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
        controller.open()
        
    }
    
    func move(item: [BaseDataSourceItem], toPath: String) {
        guard let item = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        let itemsFolders = item.compactMap { $0.parent }
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
                                    self?.successAction(elementType: .move)()
                                    //because we have animation of dismiss for this stack of view controllers we have some troubles with reloading data in root collection view
                                    //data will be updated after 0.3 seconds (time of aimation)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                        ItemOperationManager.default.filesMoved(items: item, toFolder: folder)
                                    })
                                    
                }, fail: self?.failAction(elementType: .move))
            
            }, cancel: { [weak self] in
                self?.output?.operationCancelled(type: .move)
        })
    }
    
    func copy(item: [BaseDataSourceItem], toPath: String) {
        guard let item = item as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        let folderSelector = selectFolderController()
        
        folderSelector.selectFolder(select: { [weak self] folder in
            self?.output?.operationStarted(type: .copy)
            self?.fileService.move(items: item, toPath: folder,
                                   success: self?.successAction(elementType: .copy),
                                   fail: self?.failAction(elementType: .copy))
            }, cancel: { [weak self] in
                self?.output?.operationCancelled(type: .copy)
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
        guard let items = item as? [Item] else {
            return
        }
        
        fileService.upload(items: items, toPath: "",
                           success: successAction(elementType: .sync),
                           fail: failAction(elementType: .sync))
    }
    
    func downloadDocument(items: [WrapData]?) {
        guard let items = items, !items.isEmpty else {
            return
        }
        
        let successAction = { [weak self] in
            if items.allSatisfy ({ !$0.isOwner }) {
                self?.privateShareAnalytics.sharedWithMe(action: .download, on: items.first)
            }
            self?.successAction(elementType: .downloadDocument)()
        }
        
        fileService.downloadDocuments(items: items, success: successAction, fail: failAction(elementType: .downloadDocument))
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
                let successAction = { [weak self] in
                    if item.allSatisfy ({ !$0.isOwner }) {
                        self?.privateShareAnalytics.sharedWithMe(action: .download, on: item.first)
                    }
                    self?.successAction(elementType: .download, relatedItems: item)()
                }
                
                fileService.download(items: item, toPath: "",
                                     success: successAction,
                                     fail: failAction(elementType: .download))
            }
        } else if let albums = item as? [AlbumItem] {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.Download(type: .album, count: albums.count))
            output?.startAsyncOperationDisableScreen()
            albumService.loadItemsBy(albums: albums, success: { [weak self] itemsByAlbums in
                let allItems = itemsByAlbums.flatMap { $1.filter { !$0.isLocalItem }}
                self?.output?.completeAsyncOperationEnableScreen()
                self?.fileService.download(itemsByAlbums: itemsByAlbums,
                                           success: self?.successAction(elementType: .download, relatedItems: allItems),
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
            }, fail: { errorResponse in
                UIApplication.showErrorAlert(message: errorResponse.description)
        })
    }
    
    func addToFavorites(items: [BaseDataSourceItem]) {
        guard let items = items.filter({ !$0.isLocalItem }) as? [WrapData], items.count > 0 else { return }
        fileService.addToFavourite(files: items,
                                   success: successAction(elementType: .addToFavorites),
                                   fail: failAction(elementType: .addToFavorites))
    }
    
    func removeFromFavorites(items: [BaseDataSourceItem]) {
        guard let items = items as? [Item] else { //FIXME: transform all to BaseDataSourceItem
            return
        }
        output?.operationStarted(type: .removeFromFavorites)
        fileService.removeFromFavourite(files: items,
                                        success: successAction(elementType: .removeFromFavorites),
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
            }, fail: { errorResponse in
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AddToAlbum(status: .failure))
                UIApplication.showErrorAlert(message: errorResponse.description)
        })
    }
    
    func backUp(items: [BaseDataSourceItem]) {
        
    }
    
    func removeFromAlbum(items: [BaseDataSourceItem]) {
        removeAlbumItems(items)
    }
    
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem], item: Item) {
        deletePhotosFromAlbum(items: items, item: item)
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
        guard let item = items.first as? Item else { return }
        let album = self.router.getParentUUID()
        let params = ChangeCoverPhoto(albumUUID: album,
                                      photoUUID: item.uuid)

        albumService.changeCoverPhoto(parameters: params, success: { [weak self] in
            self?.output?.operationFinished(type: .makeAlbumCover)
            ItemOperationManager.default.updatedAlbumCoverPhoto(item: item)
            }, fail: { [weak self] error in
                self?.output?.operationFailed(type: .makeAlbumCover, message: localized(.changeAlbumCoverFail))
        })
    }
    
    func makePersonThumbnail(items: [BaseDataSourceItem], personItem: Item) {
        guard let item = items.first as? Item, let personId = personItem.id else{ return }
        
        let params = PeopleChangeThumbnailParameters(personId: personId, item: item)
        
        albumService.changePeopleThumbnail(parameters: params, success: { [weak self] in
            self?.output?.operationFinished(type: .makePersonThumbnail)
            ItemOperationManager.default.updatedPersonThumbnail(item: item)
            }, fail: { [weak self] error in
                self?.output?.operationFailed(type: .makePersonThumbnail, message: localized(.changePersonThumbnailError))
        })
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
            
            controller.open()
        }
    }
    
    func delete(items: [BaseDataSourceItem], completion: @escaping VoidHandler) {
        let cancelHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .delete, label: .cancel)
            vc.close()
        }
        
        let okHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .delete, label: .ok)
            self?.output?.operationStarted(type: .delete)
            vc.close { [weak self] in
                self?.deleteItems(items)
                completion()
            }
        }
        
        trackScreen(.fileOperationConfirmPopup(.delete))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.DeletePermanentlyConfirmPopUp())
        
        let message: String
        if isAlbums(items) {
            message = TextConstants.deleteAlbumsConfirmationPopupText
        } else if items.allSatisfy({ $0.fileType == .folder }) {
            message = TextConstants.deleteFoldersConfirmationPopupText
        } else {
            message = TextConstants.deleteItemsConfirmationPopupText
        }
        let popup = PopUpController.with(title: TextConstants.deleteConfirmationPopupTitle,
                                         message: message,
                                         image: .delete,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         firstAction: cancelHandler,
                                         secondAction: okHandler)
        
        popup.open()
    }
    
    func deleteDeviceOriginal(items: [BaseDataSourceItem]) {
        guard let wrapedItems = items as? [WrapData] else {
            return
        }
        fileService.deleteLocalFiles(deleteFiles: wrapedItems, success: successAction(elementType: .deleteDeviceOriginal),
                                     fail: failAction(elementType: .deleteDeviceOriginal))
    }
    
    func endSharing(item: BaseDataSourceItem?) {
        guard let item = item as? WrapData else {
            return
        }
        let successAction = { [weak self] in
            self?.privateShareAnalytics.endShare(item: item)
            ItemOperationManager.default.didEndShareItem(uuid: item.uuid)
            self?.output?.operationFinished(type: .endSharing)
            self?.successAction(elementType: .endSharing)()
        }
        
        let failAction = { [weak self] (error: ErrorResponse) in
            self?.output?.operationFailed(type: .endSharing, message: error.description)
            self?.failAction(elementType: .endSharing)(error)
        }
        
        
        let popup = PopUpController.with(title: TextConstants.privateSharedEndSharingActionTitle,
                                         message: TextConstants.privateSharedEndSharingActionConfirmation,
                                         image: .question,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         firstAction: { vc in
                                            vc.close()
                                         },
                                         secondAction: { [weak self] vc in
                                            vc.close {
                                                self?.fileService.endSharing(file: item, success: successAction, fail: failAction)
                                            }
                                         })
        popup.open()
    }
    
    func leaveSharing(item: BaseDataSourceItem?) {
        guard let item = item as? WrapData else {
            return
        }
        let successAction = { [weak self] in
            self?.privateShareAnalytics.leaveShare(item: item)
            ItemOperationManager.default.didLeaveShareItem(uuid: item.uuid)
            self?.output?.operationFinished(type: .leaveSharing)
            self?.successAction(elementType: .leaveSharing)()
        }
        
        let failAction = { [weak self] (error: ErrorResponse) in
            self?.output?.operationFailed(type: .leaveSharing, message: error.description)
            self?.failAction(elementType: .leaveSharing)(error)
        }
        
        
        let popup = PopUpController.with(title: TextConstants.privateSharedLeaveSharingActionTitle,
                                         message: TextConstants.privateSharedLeaveSharingActionConfirmation,
                                         image: .question,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         firstAction: { vc in
                                            vc.close()
                                         },
                                         secondAction: { [weak self] vc in
                                            vc.close {
                                                self?.fileService.leaveSharing(file: item, success: successAction, fail: failAction)
                                            }
                                         })
        
        popup.open()
        
    }
    
    
    func moveToTrashShared(items: [BaseDataSourceItem]) {
        guard let items = items as? [WrapData] else {
            return
        }
        
        let cancelHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .trash, label: .cancel)
            vc.close()
        }
        
        let okHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .trash, label: .ok)
            if items.allSatisfy({ !$0.isOwner }) {
                self?.privateShareAnalytics.sharedWithMe(action: .delete, on: items.first)
            }
            self?.output?.operationStarted(type: .moveToTrashShared)
            vc.close { [weak self] in
                self?.moveToTrashShared(items)
            }
        }
        
        trackScreen(.fileOperationConfirmPopup(.trash))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.DeleteConfirmPopUp())
        
        let message = items.allSatisfy { $0.isOwner } ? TextConstants.deleteFilesText : TextConstants.privateShareMoveToTrashSharedWithMeMessage
        
        let popup = PopUpController.with(title: TextConstants.actionSheetDelete,
                                         message: message,
                                         image: .delete,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         firstAction: cancelHandler,
                                         secondAction: okHandler)
        
        popup.open()

    }
    
    
    func removeAlbums(items: [BaseDataSourceItem]) {
        let okHandler: PopUpButtonHandler = { [weak self] vc in
            self?.output?.operationStarted(type: .moveToTrash)
            vc.close { [weak self] in
                self?.removeAlbums(items)
            }
        }

        let popup = PopUpController.with(title: TextConstants.actionSheetRemove,
                                         message: TextConstants.removeAlbums,
                                         image: .delete,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         secondAction: okHandler)
        
        popup.open()
    }
    
    func emptyTrashBin() {
        let cancelHandler: PopUpButtonHandler = { [weak self] vc in
//            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .delete, label: .cancel)
            vc.close()
        }
        
        let okHandler: PopUpButtonHandler = { [weak self] vc in
            self?.output?.operationStarted(type: .emptyTrashBin)
            vc.close { [weak self] in
                self?.deleteAllFromTrashBin()
            }
        }
        
        let popup = PopUpController.with(title: TextConstants.trashBinDeleteAllConfirmTitle,
                                         message: TextConstants.trashBinDeleteAllConfirmText,
                                         image: .delete,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.trashBinDeleteAllConfirmOkButton,
                                         firstAction: cancelHandler,
                                         secondAction: okHandler)
        
        popup.open()
        
    }
    
    private func removeAlbums(_ items: [BaseDataSourceItem]) {
        guard let albums = items as? [AlbumItem] else {
            return
        }
        
        albumService.moveToTrash(albums: albums, albumItems: [], success: { [weak self] _ in
            self?.successAction(elementType: .removeAlbum)()
        }, fail: failAction(elementType: .removeAlbum))
    }
    
    private func deleteAllFromTrashBin() {
        fileService.deletAllFromTrashBin(success: successAction(elementType: .emptyTrashBin),
                                         fail: failAction(elementType: .emptyTrashBin))
    }
    
    private func sync(items: [BaseDataSourceItem]?, action: @escaping VoidHandler, fail: FailResponse?) {
        
        guard let items = items as? [WrapData] else {
            assertionFailure()
            return
        }
        
        let successClosure = { [weak self] in
            debugLog("SyncToUse - Success closure")
            DispatchQueue.main.async {
//                self?.output?.completeAsyncOperationEnableScreen()
                action()
            }
        }
        
        let failClosure: FailResponse = { [weak self] errorResponse in
            debugLog("SyncToUse - Fail closure")
            DispatchQueue.main.async {
//                self?.output?.completeAsyncOperationEnableScreen()
//                if errorResponse.errorDescription == TextConstants.canceledOperationTextError {
//                    cancel()
//                    return
//                }
                fail?(errorResponse)
            }
        }
        fileService.syncItemsIfNeeded(items, success: successClosure, fail: failClosure, syncOperations: { [weak self] syncOperations in
//            let operations = syncOperations
//            if operations != nil {
//                self?.output?.startCancelableAsync {
//                    UploadService.default.cancelSyncToUseOperations()
//                    cancel()
//                }
//            } else {
                debugLog("syncItemsIfNeeded count: \(syncOperations?.count ?? -1)")
//            }
        })
        
    }
    
    private func downloadFaceImageAlbum(item: Item) {
        let successHandler: AlbumOperationResponse = { [weak self] album in
            let albumItem = AlbumItem(remote: album)
            self?.albumService.loadItemsBy(albums: [albumItem], success: { [weak self] itemsByAlbums in
                let allItems = itemsByAlbums.flatMap { $1.filter { !$0.isLocalItem }}
                self?.fileService.download(itemsByAlbums: itemsByAlbums,
                                           success: self?.successAction(elementType: .download, relatedItems: allItems),
                                           fail: self?.failAction(elementType: .download))
            })
        }
        
        let failHandler: FailResponse = { error in
            UIApplication.showErrorAlert(message: error.description)
        }
        
        guard let id = item.id else {
            assertionFailure()
            return
        }
        
        if item.fileType == .faceImage(.people) {
            peopleService.getPeopleAlbum(id: Int(truncatingIfNeeded: id), status: .active, success: successHandler, fail: failHandler)
            
        } else if item.fileType == .faceImageAlbum(.things) {
            thingsService.getThingsAlbum(id: Int(truncatingIfNeeded: id), status: .active, success: successHandler, fail: failHandler)
            
        } else if item.fileType == .faceImage(.places) {
            placesService.getPlacesAlbum(id: Int(truncatingIfNeeded: id), status: .active, success: successHandler, fail: failHandler)
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
    
    func officeFilterAll() {
        print("officeFilterAll")
    }
    
    func officeFilterPdf() {
        print("officeFilterPdf")
    }
    
    func officeFilterWord() {
        print("officeFilterWord")
    }
    
    func officeFilterCell() {
        print("officeFilterCell")
    }
    
    func officeFilterSlide() {
        print("officeFilterSlide")
    }
}



//MARK: - Actions

extension MoreFilesActionsInteractor {
    
    func successAction(elementType: ElementTypes, itemsType: DivorseItems? = nil, relatedItems: [BaseDataSourceItem] = []) -> FileOperation {
        let success: FileOperation = { [weak self] in
            guard let self = self else {
                return
            }

            self.trackGASuccessEvent(elementType: elementType)
            
            if itemsType != nil {
                self.trackNetmeraSuccessEvent(elementType: elementType, successStatus: .success, items: relatedItems)
            }
            
            DispatchQueue.main.async {
                self.output?.operationFinished(type: elementType)
                self.router.hideSpiner()
                NotificationCenter.default.post(name: .foryouGetUpdateData, object: nil)
                // handle hide popups in HideActionService
                guard elementType != .hide else {
                    return
                }
                
                if SnackbarType(operationType: elementType) != nil {
                    self.showSnackbar(elementType: elementType, itemsType: itemsType, relatedItems: relatedItems)
                } else if let message = elementType.alertSuccessMessage(divorseItems: itemsType) {
                    self.showSuccessPopup(message: message)
                }
            }
        }
        return success
    }

    private func showSuccessPopup(message: String) {
        let popup = PopUpController.with(title: TextConstants.success,
                                         message: message,
                                         image: .success,
                                         buttonTitle: TextConstants.ok) { vc in
                                            vc.close { [weak self] in
                                                self?.output?.successPopupClosed()
                                            }
                                        }
        
        popup.open()
    }
    
    private func showSnackbar(elementType: ElementTypes, itemsType: DivorseItems? = nil, relatedItems: [BaseDataSourceItem]) {
        SnackbarManager.shared.show(elementType: elementType, relatedItems: relatedItems, itemsType: itemsType) {
            let router = RouterVC()
            switch elementType {
            case .moveToTrash:
                router.openTrashBin()
            default:
                return
            }
        }
    }
    
    private func trackGASuccessEvent(elementType: ElementTypes) {
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
            let typeToCountDictionary = NetmeraService.getItemsTypeToCount(items: items)
            typeToCountDictionary.keys.forEach {
                guard let count = typeToCountDictionary[$0], let event = NetmeraEvents.Actions.Trash(status: successStatus, type: $0, count: count) else {
                    return
                }
                AnalyticsService.sendNetmeraEvent(event: event)
            }
        case .hide:
            let typeToCountDictionary = NetmeraService.getItemsTypeToCount(items: items)
            typeToCountDictionary.keys.forEach {
                guard let count = typeToCountDictionary[$0], let event = NetmeraEvents.Actions.Hide(status: successStatus, type: $0, count: count) else {
                    return
                }
                AnalyticsService.sendNetmeraEvent(event: event)
            }
        case .unhide:
            let typeToCountDictionary = NetmeraService.getItemsTypeToCount(items: items)
            typeToCountDictionary.keys.forEach {
                guard let count = typeToCountDictionary[$0], let event = NetmeraEvents.Actions.Unhide(status: successStatus, type: $0, count: count) else {
                    return
                }
                AnalyticsService.sendNetmeraEvent(event: event)
            }
        case .delete:
            let typeToCountDictionary = NetmeraService.getItemsTypeToCount(items: items)
            typeToCountDictionary.keys.forEach {
                guard let count = typeToCountDictionary[$0], let event = NetmeraEvents.Actions.Delete(status: successStatus, type: $0, count: count) else {
                    return
                }
                AnalyticsService.sendNetmeraEvent(event: event)
            }
        case .restore:
            let typeToCountDictionary = NetmeraService.getItemsTypeToCount(items: items)
            typeToCountDictionary.keys.forEach {
                guard let count = typeToCountDictionary[$0], let event = NetmeraEvents.Actions.Restore(status: successStatus, type: $0, count: count) else {
                    return
                }
                AnalyticsService.sendNetmeraEvent(event: event)
            }
        case .addToFavorites:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.AddToFavorites(status: successStatus))
        case .removeFromAlbum:
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.RemoveFromAlbum(status: successStatus))
        default:
            break
        }
    }
    
    func failAction(elementType: ElementTypes, relatedItems: [BaseDataSourceItem] = []) -> FailResponse {
        let failResponse: FailResponse  = { [weak self] value in
            self?.trackNetmeraSuccessEvent(elementType: elementType, successStatus: .failure, items: relatedItems)
            DispatchQueue.toMain {
                if value.isOutOfSpaceError {
                    debugLog("failAction 1 isOutOfSpaceError")
                    //FIXME: currently UploadService handles this
//                    if self?.router.getViewControllerForPresent() is PhotoVideoDetailViewController {
//                        debugLog("failAction 2 showOutOfSpaceAlert")
//                        self?.output?.showOutOfSpaceAlert(failedType: elementType)
//                    }
                } else {
                    debugLog("failAction 3 \(value.description)")
                    self?.output?.operationFailed(type: elementType, message: value.description)
                }
            }
        }
        return failResponse
    }
    
    private func removeItemsFromPlayer(items: [Item]) {
        player.remove(listItems: items)
    }
    
    private func trackScreen(_ screen: AnalyticsAppScreens) {
        analyticsService.logScreen(screen: screen)
        analyticsService.trackDimentionsEveryClickGA(screen: screen)
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
                self?.failAction(elementType: type, relatedItems: items)(errorResponse)
            } else {
                let itemsType: DivorseItems
                if self?.isAlbums(items) == true {
                    itemsType = .albums
                    
                } else if photosVideos.allSatisfy({ $0.fileType == .folder }) {
                    itemsType = .folders
                    
                } else {
                    itemsType = .items
                }
                
                self?.successAction(elementType: type, itemsType: itemsType, relatedItems: items)()
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
        analyticsService.trackFileOperationGAEvent(operationType: .unhide, items: items)
        fileService.unhide(items: items, success: success, fail: fail)
    }
    
    private func unhideAlbums(_ items: [AlbumItem], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        analyticsService.trackAlbumOperationGAEvent(operationType: .unhide, albums: items)
        fileService.unhideAlbums(items, success: success, fail: fail)
    }
    
    private func unhideFIRAlbums(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        if let items = items as? [PeopleItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .unhide, itemsType: .people, itemsCount: items.count)
            fileService.unhidePeople(items: items, success: success, fail: fail)

        } else if let items = items as? [ThingsItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .unhide, itemsType: .things, itemsCount: items.count)
            fileService.unhideThings(items: items, success: success, fail: fail)

        } else if let items = items as? [PlacesItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .unhide, itemsType: .places, itemsCount: items.count)
            fileService.unhidePlaces(items: items, success: success, fail: fail)

        }
    }
}

//MARK: - MOVETOTRASH
extension MoreFilesActionsInteractor {
    
    private func moveToTrash(_ items: [BaseDataSourceItem]) {
        divorceItems(type: .moveToTrash,
                 items: items,
                 itemsOperation:
        { [weak self] items, success, fail in
                self?.moveToTrashSelectedItems(items, success: success, fail: fail)
        },
                 
                 albumsOperation:
        { [weak self] items, success, fail in
                self?.moveToTrashAlbums(items, success: success, fail: fail)
        },
                 
                 firOperation:
        { [weak self] items, success, fail in
                self?.moveToTrashFIRAlbums(items, success: success, fail: fail)
        })
    }
    
    private func moveToTrashSelectedItems(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        let moveToTrashItems = items.filter { !$0.isLocalItem && !$0.isReadOnlyFolder }
        guard !moveToTrashItems.isEmpty else {
            return
        }
        
        analyticsService.trackFileOperationGAEvent(operationType: .trash, items: moveToTrashItems)
        fileService.moveToTrash(files: moveToTrashItems, success: { [weak self] in
            self?.removeItemsFromPlayer(items: moveToTrashItems)
            success()
        }, fail: fail)
    }
    
    private func moveToTrashAlbums(_ items: [AlbumItem], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        analyticsService.trackAlbumOperationGAEvent(operationType: .trash, albums: items)
        albumService.moveToTrash(albums: items, success: { _ in
            success()
        }, fail: fail)
    }
    
    private func moveToTrashFIRAlbums(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        if let items = items as? [PeopleItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .trash, itemsType: .people, itemsCount: items.count)
            fileService.moveToTrashPeople(items: items, success: success, fail: fail)

        } else if let items = items as? [ThingsItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .trash, itemsType: .things, itemsCount: items.count)
            fileService.moveToTrashThings(items: items, success: success, fail: fail)

        } else if let items = items as? [PlacesItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .trash, itemsType: .places, itemsCount: items.count)
            fileService.deletePlaces(items: items, success: success, fail: fail)
        }
    }
    
    private func moveToTrashShared(_ items: [Item]) {
        //only one is allowed for now
        guard let item = items.first else {
            return
        }
        
        let successAction = { [weak self] in
            self?.output?.operationFinished(type: .moveToTrashShared)
            self?.removeItemsFromPlayer(items: items)
            ItemOperationManager.default.didMoveToTrashSharedItems(items)
            self?.successAction(elementType: .moveToTrashShared)()
        }
        
        let failAction = { [weak self] (error: ErrorResponse) in
            self?.output?.operationFailed(type: .moveToTrashShared, message: error.description)
            self?.failAction(elementType: .moveToTrashShared)(error)
        }
        
        analyticsService.trackFileOperationGAEvent(operationType: .trash, items: items)
        
        fileService.moveToTrashShared(file: item, success: successAction, fail: failAction)
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
        analyticsService.trackFileOperationGAEvent(operationType: .delete, items: items)
        fileService.delete(items: items, success: { [weak self] in
            if #available(iOS 14.0, *) {
                if !SyncServiceManager.shared.hasExecutingSync, CacheManager.shared.isCacheActualized {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            self?.removeItemsFromPlayer(items: items)
            success()
        }, fail: fail)
    }
    
    private func deleteAlbums(_ items: [AlbumItem], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        analyticsService.trackAlbumOperationGAEvent(operationType: .delete, albums: items)
        albumService.completelyDelete(albums: items, success: { _ in
            success()
        }, fail: { errorResponse in
            fail(errorResponse)
        })
    }
    
    private func deleteFIRAlbums(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        if let items = items as? [PeopleItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .delete, itemsType: .people, itemsCount: items.count)
            fileService.deletePeople(items: items, success: success, fail: fail)

        } else if let items = items as? [ThingsItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .delete, itemsType: .things, itemsCount: items.count)
            fileService.deleteThings(items: items, success: success, fail: fail)

        } else if let items = items as? [PlacesItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .delete, itemsType: .places, itemsCount: items.count)
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
        analyticsService.trackFileOperationGAEvent(operationType: .restore, items: items)
        fileService.putBack(items: items, success: { [weak self] in
            self?.removeItemsFromPlayer(items: items)
            success()
        }, fail: fail)
    }
    
    private func putBackAlbums(_ items: [AlbumItem], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        analyticsService.trackAlbumOperationGAEvent(operationType: .restore, albums: items)
        fileService.putBackAlbums(items, success: success, fail: fail)
    }
    
    private func putBackFIRAlbums(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        if let items = items as? [PeopleItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .restore, itemsType: .people, itemsCount: items.count)
            fileService.putBackPeople(items: items, success: success, fail: fail)

        } else if let items = items as? [ThingsItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .restore, itemsType: .things, itemsCount: items.count)
            fileService.putBackThings(items: items, success: success, fail: fail)

        } else if let items = items as? [PlacesItem] {
            analyticsService.trackFileOperationGAEvent(operationType: .restore, itemsType: .places, itemsCount: items.count)
            fileService.putBackPlaces(items: items, success: success, fail: fail)

        }
    }
}

extension MoreFilesActionsInteractor {
    private func isAlbums(_ items: [Any]) -> Bool {
        return items is [PlacesItem] ||
            items is [PeopleItem] ||
            items is [ThingsItem] ||
            items is [AlbumItem]
    }
}
