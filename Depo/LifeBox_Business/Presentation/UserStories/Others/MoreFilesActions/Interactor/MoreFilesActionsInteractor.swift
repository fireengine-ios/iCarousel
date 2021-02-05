//
//  MoreFilesActionsInteractor.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import WidgetKit

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
            return TextConstants.actionShareCopy
        case .link:
            return TextConstants.actionSheetShareShareViaLink
        case .private:
            return TextConstants.actionSharePrivately
        }
    }
    
    static func allowedTypes(for items: [BaseDataSourceItem]) -> [ShareTypes] {
        guard let items = items as? [Item] else {
            assertionFailure()
            return []
        }
        
        let isOriginallDisabled = items.contains(where: { !($0.privateSharePermission?.granted?.contains(.read) ?? false) })
        //TODO: check write_acl for private share when it's available on BE
//        let isPrivatelDisabled = items.contains(where: { !($0.privateSharePermission?.granted?.contains(.writeAcl) ?? false) })
        
        var allowedTypes = [ShareTypes]()
        
        if items.contains(where: { $0.fileType == .folder}) {
            allowedTypes = [.original, .private]
        } else if items.contains(where: { return $0.fileType != .image && $0.fileType != .video && !$0.fileType.isDocumentPageItem && $0.fileType != .audio}) {
            allowedTypes = []
        } else {
            allowedTypes = [.original, .private]
        }
        
        if items.count > NumericConstants.numberOfSelectedItemsBeforeLimits || isOriginallDisabled {
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
    
    private lazy var hiddenService = HiddenService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var photoEditImageDownloader = PhotoEditImageDownloader()
    private lazy var privateShareAnalytics = PrivateShareAnalytics()
    
    
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
        controler.view.tintColor = ColorConstants.darkBlueColor
        
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
                
                let objectsToShare = [url]
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
            
            }, fail: failAction(elementType: .share))
    }
    
    func info(item: [BaseDataSourceItem], isRenameMode: Bool) {
        self.output?.operationFinished(type: .info)
        
        guard let item = item.first, let infoController = router.fileInfo(item: item) as? FileInfoViewController else {
            return
        }
        
        if let topViewController = RouterVC().getViewControllerForPresent() as? PhotoVideoDetailViewInput, !UIDevice.current.orientation.isLandscape {
            topViewController.showBottomDetailView()
        } else {
            router.pushOnPresentedView(viewController: infoController)
        }
        
        if isRenameMode {
            infoController.startRenaming()
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
        
        let popup = PopUpController.with(title: TextConstants.actionSheetDelete,
                                         message: TextConstants.deleteFilesText,
                                         image: .delete,
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.ok,
                                         firstAction: cancelHandler,
                                         secondAction: okHandler)
        
        router.presentViewController(controller: popup, animated: false)
        
    }
    
    func restore(items: [BaseDataSourceItem]) {
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
            }
        }
        
        trackScreen(.fileOperationConfirmPopup(.restore))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.RestoreConfirmPopUp())
        

        let message: String
        if items.allSatisfy({ $0.fileType == .folder }) {
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
        
        router.presentViewController(controller: controller)
        router.hideSpiner()
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
    
    func backUp(items: [BaseDataSourceItem]) {
        
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
        let cancelHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .delete, label: .cancel)
            vc.close()
        }
        
        let okHandler: PopUpButtonHandler = { [weak self] vc in
            self?.analyticsService.trackFileOperationPopupGAEvent(operationType: .delete, label: .ok)
            self?.output?.operationStarted(type: .delete)
            vc.close { [weak self] in
                self?.deleteItems(items)
            }
        }
        
        trackScreen(.fileOperationConfirmPopup(.delete))
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.DeletePermanentlyConfirmPopUp())
        
        let message: String
        if items.allSatisfy({ $0.fileType == .folder }) {
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
        
        router.presentViewController(controller: popup, animated: false)
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
        
        router.presentViewController(controller: popup, animated: false)
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
        
        router.presentViewController(controller: popup, animated: false)
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
        
        router.presentViewController(controller: popup, animated: false)
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
        
        router.presentViewController(controller: popup, animated: false)
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
    
    func trackEvent(elementType: ElementTypes) {
        switch elementType {
        case .print:
            analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .print)
        default:
            break
        }
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
                
                self.output?.successPopupWillAppear()
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
        router.presentViewController(controller: popup)
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
        case .delete:
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

    private func divorceItems(
        type: ElementTypes,
        items: [BaseDataSourceItem],
        itemsOperation: @escaping DivorceItemsOperation)
    {
        output?.startAsyncOperationDisableScreen()

        var photosVideos = [Item]()

        items.forEach {
            if let item = $0 as? Item {
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
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.output?.completeAsyncOperationEnableScreen()
            if let error = error {
                let errorResponse = ErrorResponse.error(error)
                self?.failAction(elementType: type, relatedItems: items)(errorResponse)
            } else {
                let itemsType: DivorseItems
                if photosVideos.allSatisfy({ $0.fileType == .folder }) {
                    itemsType = .folders
                    
                } else {
                    itemsType = .items
                }
                
                self?.successAction(elementType: type, itemsType: itemsType, relatedItems: items)()
            }
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
    
    private func moveToTrashShared(_ items: [Item]) {
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
        
        fileService.moveToTrashShared(files: items, success: successAction, fail: failAction)
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
            })
    }
    
    private func deleteSelectedItems(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        analyticsService.trackFileOperationGAEvent(operationType: .delete, items: items)
        fileService.delete(items: items, success: { [weak self] in
            self?.removeItemsFromPlayer(items: items)
            success()
        }, fail: fail)
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
            })
    }
    
    private func putBackSelectedItems(_ items: [Item], success: @escaping FileOperation, fail: @escaping ((Error) -> Void)) {
        analyticsService.trackFileOperationGAEvent(operationType: .restore, items: items)
        fileService.putBack(items: items, success: { [weak self] in
            self?.removeItemsFromPlayer(items: items)
            success()
        }, fail: fail)
    }
}
