//
//  AlertFilesActionsSheetPresenter.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

typealias AlertActionsCallback = ([AlertFilesAction]) -> Void

class AlertFilesActionsSheetPresenter: MoreFilesActionsPresenter, AlertFilesActionsSheetModuleInput {
    
    private let semaphore = DispatchSemaphore(value: 0)
    
    let rightButtonBox = CGRect(x: Device.winSize.width - 45, y: -15, width: 0, height: 0)
    // MARK: Module Input
    
    func showSelectionsAlertSheet() {
        constractActions(with: [.select, .selectAll], for: nil) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: nil)
            }
        }
    }
    
    func showAlertSheet(with types: [ElementTypes], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        self.constractActions(with: types, for: nil) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { /// main thread - no need for weak, but just in case
                    return
                }
                self.presentAlertSheet(with: actions, presentedBy: sender)
            }
        }
    }
    
    func showAlertSheet(with items: [BaseDataSourceItem], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        guard let items = items as? [Item], items.count > 0 else {
            return
        }
        constractActions(with: adjastActionTypes(for: items), for: nil) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender)
            }
        }
    }
    
    func showAlertSheet(with types: [ElementTypes], items: [BaseDataSourceItem], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        showAlertSheet(with: types, items: items, presentedBy: sender, onSourceView: sourceView, excludeTypes: [ElementTypes]())
    }
    
    func showAlertSheet(with types: [ElementTypes],
                        items: [BaseDataSourceItem],
                        presentedBy sender: Any?,
                        onSourceView sourceView: UIView?,
                        excludeTypes: [ElementTypes]) {
        constractSpecifiedActions(with: types, for: items, excludeTypes: excludeTypes) {[weak self] (actions) in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender)
            }
        }
        
    }
    
    func showSpecifiedAlertSheet(with item: BaseDataSourceItem, status: ItemStatus, presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController? = nil) {
        // TODO: Facelift, file name & info in menu header
//        let headerAction = UIAlertAction(title: item.name ?? "file", style: .default, handler: {_ in
//
//        })
//        headerAction.isEnabled = false
        
        let types = ElementTypes.specifiedMoreActionTypes(for: status, item: item)
        
        if item.fileType == .photoAlbum {
            let album = AlbumItem(uuid: item.uuid,
                                  name: item.name,
                                  creationDate: item.creationDate,
                                  lastModifiDate: item.lastModifiDate,
                                  fileType: item.fileType,
                                  syncStatus: item.syncStatus,
                                  isLocalItem: item.isLocalItem)
            
            constractActions(with: types, for: [album]) { [weak self] actions in
                DispatchQueue.main.async { [weak self] in
                    self?.presentAlertSheet(with: /*[headerAction] +*/ actions, presentedBy: sender, viewController: viewController)
                }
            }
        } else if item is Item || status == .trashed {
            constractActions(with: types, for: [item]) { [weak self] actions in
                DispatchQueue.main.async { [weak self] in
                    self?.presentAlertSheet(with: /*[headerAction] +*/ actions, presentedBy: sender, viewController: viewController)
                }
            }
        }
    }
    
    func showSpecifiedMusicAlertSheet(with item: WrapData, status: ItemStatus, presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController?) {
        let types = ElementTypes.muisicPlayerElementConfig(for: status, item: item)
        
        constractActions(with: types, for: [item]) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender, viewController: viewController)
            }
        }
    }
    
    func showNotification(with types: [ElementTypes], presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController?) {
        constractNotificationAction(with: types) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender, viewController: viewController)
            }
        }
    }
    
    func show(with types: [ElementTypes], for items: [WrapData], presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController?) {
        constractActions(with: types, for: items) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender, viewController: viewController)
            }
        }
    }
    
    private func adjastActionTypes(for items: [Item]) -> [ElementTypes] {
        var actionTypes: [ElementTypes] = []
        if items.count == 1, let item = items.first {
            
            switch item.fileType {
            case .audio:
                //This on for player
                actionTypes = [.musicDetails, .addToPlaylist]//, .move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append(.moveToTrash)
                
            case .folder:
                break
            case .image:
                actionTypes = [.createStory, .move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append((item.albums != nil) ? .removeFromAlbum : .addToAlbum)
                actionTypes.append((item.isLocalItem) ? .backUp : .addToCmeraRoll)
                if !item.isLocalItem {
                    actionTypes.append(.moveToTrash)
                }
            case .video:
                actionTypes = [.move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append((item.isLocalItem) ? .backUp : .addToCmeraRoll)
                
            case .photoAlbum: // TODO add for Alboum
                break
                
            case .musicPlayList: // TODO Add for MUsic
                break
                
            case .application(let fileExtencion):
                switch fileExtencion {
                    
                case .rar, .zip:
                    actionTypes = [.copy, .move]
                    actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                    actionTypes.append(.moveToTrash)
                    
                case .doc, .pdf, .txt, .ppt, .xls, .html, .pptx:
                    actionTypes = [.move, .copy, .documentDetails]
                    actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                    actionTypes.append(.moveToTrash)
                    
                default:
                    break
                }
            default:
                break
            }
            
        }
        return actionTypes
    }
    
    private func constractSpecifiedActions(with types: [ElementTypes],
                                           for items: [BaseDataSourceItem]?,
                                           excludeTypes: [ElementTypes] = [ElementTypes](),
                                           succes: @escaping AlertActionsCallback) {
        DispatchQueue.global().async { [weak self] in
            var filteredActionTypes = types
            
            if let remoteItems = items?.filter({ !$0.isLocalItem }) as? [Item], remoteItems.count > 0 {
                if remoteItems.contains(where: { !$0.favorites }) {
                    if !filteredActionTypes.contains(.addToFavorites) {
                        filteredActionTypes.append(.addToFavorites)
                    }
                } else if let addToFavoritesIndex = filteredActionTypes.firstIndex(of: .addToFavorites) {
                    filteredActionTypes.remove(at: addToFavoritesIndex)
                }
                
                if !remoteItems.contains(where: { !($0.fileType.isDocumentPageItem || $0.fileType == .audio) }) {
                    if !filteredActionTypes.contains(.downloadDocument) {
                        filteredActionTypes.append(.downloadDocument)
                    }
                }
                
                if remoteItems.contains(where: { $0.favorites }) {
                    if !filteredActionTypes.contains(.removeFromFavorites) {
                        filteredActionTypes.append(.removeFromFavorites)
                    }
                } else if let removeFromFavorites = filteredActionTypes.firstIndex(of: .removeFromFavorites) {
                    filteredActionTypes.remove(at: removeFromFavorites)
                }
                
                if remoteItems.first(where: { !$0.isReadOnlyFolder }) == nil {
                    filteredActionTypes.remove(.moveToTrash)
                }
                
                if let index = filteredActionTypes.firstIndex(of: .deleteDeviceOriginal) {
                    MediaItemOperationsService.shared.getLocalDuplicates(remoteItems: remoteItems, duplicatesCallBack: { [weak self] items in
                        let localDuplicates = items
                        if localDuplicates.isEmpty {
                            filteredActionTypes.remove(at: index)
                        }
                        self?.semaphore.signal()
                    })
                    self?.semaphore.wait()
                }
            } else {
                if let printIndex = filteredActionTypes.firstIndex(of: .print) {
                    filteredActionTypes.remove(at: printIndex)
                }
            }
            
            filteredActionTypes = filteredActionTypes.filter({ !excludeTypes.contains($0) })
            if let `self` = self {
                self.constractActions(with: filteredActionTypes, for: items) { actions in
                    succes(actions)
                }
            }
        }
    }
    
    private func constractNotificationAction(with types: [ElementTypes], sender: Any? = nil,
                                 actionsCallback: @escaping AlertActionsCallback) {
        actionsCallback(types.map { type in
            var action: AlertFilesAction
            switch type {
            case .deleteAll, .selectMode:
                action = AlertFilesAction(title: type.actionTitle(), icon: type.icon) { [weak self] in
                    self?.handleNotificationAction(type: type)
                }
            case .onlyUnreadOn, .onlyUnreadOff, .onlyShowAlertsOn, .onlyShowAlertsOff:
                action = AlertFilesAction(title: type.actionTitle(), icon: type.icon, isTemplate: false) { [weak self] in
                    self?.handleNotificationAction(type: type)
                }
            default:
                action = AlertFilesAction()
                break
            }
            return action
        })
    }
    
    private func constractActions(with types: [ElementTypes],
                                  for items: [BaseDataSourceItem]?, sender: Any? = nil,
                                  actionsCallback: @escaping AlertActionsCallback) {

        var filteredTypes = types
        if !PrintService.isEnabled {
            filteredTypes = types.filter({ $0 != .print }) //FE-2439 - Removing Print Option for Turkish (TR) language
        }
        basePassingPresenter?.getSelectedItems { [weak self] selectedItems in
            //FIXME: this part can actualy be wraped into background thread
            guard let self = self else {
                return
            }
            
            var tempoItems = items
            if tempoItems == nil || tempoItems?.count == 0 {
                tempoItems = selectedItems
            }
            
            guard let currentItems = tempoItems else {
                actionsCallback([])
                return
            }
            actionsCallback(filteredTypes.map { type in
                var action: AlertFilesAction
                switch type {
                case .info,
                     .edit,
                     .download,
                     .downloadDocument,
                     .moveToTrash,
                     .unhide,
                     .restore,
                     .move,
                     .emptyTrashBin,
                     .photos,
                     .addToAlbum,
                     .createAlbum,
                     .albumDetails,
                     .shareAlbum,
                     .makeAlbumCover,
                     .removeFromAlbum,
                     .backUp,
                     .copy,
                     .createStory,
                     .iCloudDrive,
                     .lifeBox,
                     .more,
                     .musicDetails,
                     .addToPlaylist,
                     .addToCmeraRoll,
                     .addToFavorites,
                     .removeFromFavorites,
                     .documentDetails,
                     .select,
                     .selectAll,
                     .deSelectAll,
                     .print,
                     .rename,
                     .delete,
                     .removeAlbum,
                     .changeCoverPhoto,
                     .changePeopleThumbnail,
                     .removeFromFaceImageAlbum,
                     .instaPick,
                     .endSharing,
                     .leaveSharing,
                     .moveToTrashShared,
                     .makePersonThumbnail,
                     .shareOriginal,
                     .shareLink,
                     .sharePrivate,
                     .galleryAll,
                     .galleryPhotos,
                     .galleryVideos,
                     .gallerySync,
                     .galleryUnsync,
                     .officeFilterAll,
                     .officeFilterPdf,
                     .officeFilterWord,
                     .officeFilterCell,
                     .officeFilterSlide:

                    //
                    action = AlertFilesAction(title: type.actionTitle()) { [weak self] in
                        self?.handleAction(type: type, items: currentItems)
                    }

                case .hide:
                    action = AlertFilesAction(title: type.actionTitle(fileType: currentItems.first?.fileType)) { [weak self] in
                        self?.handleAction(type: type, items: currentItems)
                    }
                    
                case .smash:
                    action = AlertFilesAction(title: type.actionTitle()) {
                        self.handleAction(type: type, items: currentItems, sender: sender)
                    }

                case .share:
                    action = AlertFilesAction(title: type.actionTitle()) {
                        self.handleAction(type: type, items: currentItems, sender: sender)
                    }

                case .deleteDeviceOriginal:
                    if let itemsArray = items as? [Item] {
                        let serverObjects = itemsArray.filter({
                            !$0.isLocalItem
                        })
                        
                        action = AlertFilesAction(title: TextConstants.actionSheetDeleteDeviceOriginal) {
                            self.didSelectDeleteDeviceOriginal(serverObjects: serverObjects)
                        }
                        
                    } else {
                        action = AlertFilesAction(title: type.actionTitle()) {
                            self.handleAction(type: .deleteDeviceOriginal, items: currentItems)
                        }
                    }
                case .sync, .syncInProgress, .undetermend:
                    action = AlertFilesAction()
                default:
                    action = AlertFilesAction()
                    break
                }

                action.icon = type.icon
                return action
            })
        }
    }
    
    private func didSelectDeleteDeviceOriginal(serverObjects:[Item]) {
        MediaItemOperationsService.shared.getLocalDuplicates(remoteItems: serverObjects, duplicatesCallBack: { [weak self] items in
            self?.interactor.deleteDeviceOriginal(items: items)
        })
    }
    
    func onlyPresentAlertSheet(with elements: [ElementTypes], for objects:[Item], sender: Any?) {
        constractActions(with: elements, for: objects) { [weak self] actions in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender)
            }
        }
    }

    private func presentAlertSheet(with actions: [AlertFilesAction], presentedBy sender: Any?, onSourceView sourceView: UIView? = nil, viewController: UIViewController? = nil) {
        if !actions.isEmpty {
            let actionsViewController = AlertFilesActionsViewController()
            actionsViewController.configure(with: actions)
            actionsViewController.presentAsDrawer()
        }
    }
    
    private func getSourceRect(sender: Any?, controller: ViewController?) -> CGRect {
        var newSourceRect = CGRect()
        
        let sourceController: UIViewController
        if let unwrapedVC = controller {
            sourceController = unwrapedVC 
        } else if let rootVC = RouterVC().getViewControllerForPresent() {
            sourceController = rootVC
        } else {
            return newSourceRect
        }
        
        if let pressedBarButton = sender as? UIButton {
            var sourceRectFrame = pressedBarButton.convert(pressedBarButton.frame, to: sourceController.view)
            if sourceRectFrame.origin.x > sourceController.view.bounds.width {
                sourceRectFrame = CGRect(origin: CGPoint(x: pressedBarButton.frame.origin.x, y: pressedBarButton.frame.origin.y + 20), size: pressedBarButton.frame.size)
            }
            newSourceRect = sourceRectFrame
        } else if let _ = sender as? UIBarButtonItem {
            if sourceController.navigationController?.navigationBar.isTranslucent == true {
                var frame = rightButtonBox
                frame.origin.y = 44
                newSourceRect = frame
            } else {
                newSourceRect = rightButtonBox
            }
        }
        return newSourceRect
    }
    
    func handleNotificationAction(type: ElementTypes) {
        trackNetmeraAction(type: type)
        
        switch type {
        case .deleteAll:
            basePassingPresenter?.delete(all: true)
        case .selectMode:
            basePassingPresenter?.selectModeSelected()
        case .onlyUnreadOn:
            basePassingPresenter?.showOnly(withType: .onlyUnreadOn)
        case .onlyUnreadOff:
            basePassingPresenter?.showOnly(withType: .onlyUnreadOff)
        case .onlyShowAlertsOn:
            basePassingPresenter?.showOnly(withType: .onlyShowAlertsOn)
        case .onlyShowAlertsOff:
            basePassingPresenter?.showOnly(withType: .onlyShowAlertsOff)
        default:
            break
        }
    }
    
    func handleAction(type: ElementTypes, items: [BaseDataSourceItem], sender: Any? = nil) {
        trackNetmeraAction(type: type)
        
        switch type {
        case .info:
            interactor.info(item: items, isRenameMode: false)
        case .edit:
            UIApplication.topController()?.showSpinner()
            interactor.edit(item: items, completion: {
                UIApplication.topController()?.hideSpinner()
            })
        case .download:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.download(item: items)
                basePassingPresenter?.stopModeSelected()
            } else {
                let text = String(format: TextConstants.downloadLimitAllert, allowedNumberLimit)
                UIApplication.showErrorAlert(message: text)
            }
        case .downloadDocument:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.downloadDocument(items: items as? [WrapData])
                basePassingPresenter?.stopModeSelected()
            } else {
                let text = String(format: TextConstants.downloadLimitAllert, allowedNumberLimit)
                UIApplication.showErrorAlert(message: text)
            }
        case .moveToTrash:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.moveToTrash(items: items)
            } else {
                let text = String(format: TextConstants.deleteLimitAllert, allowedNumberLimit)
                UIApplication.showErrorAlert(message: text)
            }
            
        case .hide:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.hide(items: items)
            } else {
                let text = String(format: TextConstants.hideLimitAllert, allowedNumberLimit)
                UIApplication.showErrorAlert(message: text)
            }
            
        case .unhide:
            interactor.unhide(items: items)
            
        case .restore:
            interactor.restore(items: items, completion: {
                debugPrint("Restore is done")
            })
            
        case .move:
            interactor.move(item: items, toPath: "")
            
        case .share:
            interactor.share(item: items, sourceRect: self.getSourceRect(sender: sender, controller: nil))
            
        case .emptyTrashBin:
            interactor.emptyTrashBin()

        //Photos and albumbs
        case .photos:
            interactor.photos(items: items)
            
        case .createAlbum:
            debugPrint("Can not create album for now")
            
        case .addToAlbum:
            interactor.addToAlbum(items: items)

        case .albumDetails:
            interactor.albumDetails(items: items)

        case .shareAlbum:
            interactor.shareAlbum(items: items)
            
        case .makeAlbumCover:
            interactor.makeAlbumCover(items: items)

        case .removeFromAlbum:
            interactor.removeFromAlbum(items: items)
            
        case .backUp:
            interactor.backUp(items: items)
            
        case .copy:
            interactor.copy(item: items, toPath: "")
            
        case .createStory:
            let images = items.filter({ $0.fileType == .image })
            if images.count <= NumericConstants.maxNumberPhotosInStory {
                interactor.createStory(items: images)
                basePassingPresenter?.stopModeSelected()
            } else {
                let text = String(format: TextConstants.createStoryPhotosMaxCountAllert, NumericConstants.maxNumberPhotosInStory)
                UIApplication.showErrorAlert(message: text)
            }
            
        case .iCloudDrive:
            interactor.iCloudDrive(items: items)

        case .lifeBox:
            interactor.lifeBox(items: items)
            
        case .more:
            interactor.more(items: items)
            
        case .musicDetails:
            interactor.musicDetails(items: items)
            
        case .addToPlaylist:
            interactor.addToPlaylist(items: items)
            
        case .addToCmeraRoll:
            interactor.downloadToCmeraRoll(items: items)
            
        case .addToFavorites:
            basePassingPresenter?.stopModeSelected()
            interactor.addToFavorites(items: items)
            
        case .removeFromFavorites:
            interactor.removeFromFavorites(items: items)
            basePassingPresenter?.stopModeSelected()
            
        case .documentDetails:
            interactor.documentDetails(items: items)
            
        case .select:
            basePassingPresenter?.selectModeSelected()
//                    self.interactor.//TODO: select and select all pass to grid's presenter
            
        case .selectAll:
            basePassingPresenter?.selectAllModeSelected()
//                    self.interactor.selectAll(items: <#T##[Item]#>)??? //TODO: select and select all pass to grid's presenter
        
        case .deSelectAll:
            basePassingPresenter?.deSelectAll()
            
        case .print:
            basePassingPresenter?.printSelected()

        case .smash:
            let controller = RouterVC().getViewControllerForPresent()
            controller?.showSpinner()
            self.interactor.smash(item: items) {
                controller?.hideSpinner()
            }
            self.basePassingPresenter?.stopModeSelected()

        case .rename:
            interactor.info(item: items, isRenameMode: true)
            
        case .delete:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.delete(items: items) {
                    debugPrint("Restore is Done")
                }
            } else {
                let text = String(format: TextConstants.deleteLimitAllert, allowedNumberLimit)
                UIApplication.showErrorAlert(message: text)
            }
            
        case .removeAlbum:
            interactor.removeAlbums(items: items)
            
        case .deleteDeviceOriginal:
            interactor.deleteDeviceOriginal(items: items)
        
        case .changeCoverPhoto:
            basePassingPresenter?.changeCover()

        case .changePeopleThumbnail:
            basePassingPresenter?.changePeopleThumbnail()
            
        case .makePersonThumbnail:
            if let item = basePassingPresenter?.getFIRParent() {
                interactor.makePersonThumbnail(items: items, personItem: item)
            }
        case .removeFromFaceImageAlbum:
            if let item = basePassingPresenter?.getFIRParent() {
                interactor.deleteFromFaceImageAlbum(items: items, item: item)
            }

        case .instaPick:
            basePassingPresenter?.openInstaPick()
            
        case .endSharing:
            //currently only for one file is supported
            interactor.endSharing(item: items.first)
            
        case .leaveSharing:
            //currently only for one file is supported
            self.interactor.leaveSharing(item: items.first)
            
        case .moveToTrashShared:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.moveToTrashShared(items: items)
            } else {
                let text = String(format: TextConstants.deleteLimitAllert, allowedNumberLimit)
                UIApplication.showErrorAlert(message: text)
            }
        case .shareOriginal, .shareLink, .sharePrivate:
            interactor.handleShareAction(type: type, sourceRect: self.getSourceRect(sender: sender, controller: nil), items: items)
        case .galleryAll, .gallerySync, .galleryUnsync, .galleryVideos, .galleryPhotos:
            ItemOperationManager.default.elementTypeChanged(type: type)
            
        case .officeFilterAll:
            interactor.officeFilterByType(documentType: .all)
            
        case .officeFilterPdf:
            interactor.officeFilterByType(documentType: .pdf)
            
        case .officeFilterWord:
            interactor.officeFilterByType(documentType: .word)
            
        case .officeFilterCell:
            interactor.officeFilterByType(documentType: .cell)
            
        case .officeFilterSlide:
            interactor.officeFilterByType(documentType: .slide)
            
        default:
            break
        }
    }
    
    func handleShare(type: ShareTypes, items: [BaseDataSourceItem], sender: Any?) {
        let sourceRect = getSourceRect(sender: sender, controller: nil)
        interactor.handleShare(type: type, sourceRect: sourceRect, items: items)
    }
    
    private func trackNetmeraAction(type: ElementTypes) {
        var button: NetmeraEventValues.ButtonName?
        
        switch type {
        case .info, .albumDetails:
            button = .info
        case .edit:
            button = .edit
        case .download, .downloadDocument:
            button = .download
        case .moveToTrash,
             .moveToTrashShared,
             .delete,
             .removeAlbum,
             .removeFromAlbum,
             .removeFromFaceImageAlbum:
            button = .delete
        case .hide:
            button = .hide
        case .unhide:
            button = .unhide
        case .restore:
            button = .restore
        case .share, .shareAlbum:
            button = .share
        case .addToAlbum:
            button = .addToAlbum
        case .addToFavorites:
            button = .addToFavorites
        case .removeFromFavorites:
            button = .removeFromFavorites
        case .print:
            button = .print
        case .endSharing:
            button = .endSharing
        case .leaveSharing:
            button = .leaveSharing
        default:
            button = nil
        }
        
        if let button = button {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: button))
        }
    }
}
