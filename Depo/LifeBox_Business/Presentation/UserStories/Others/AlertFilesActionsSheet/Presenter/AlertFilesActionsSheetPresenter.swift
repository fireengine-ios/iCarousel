//
//  AlertFilesActionsSheetPresenter.swift
//  Depo
//
//  Created by Aleksandr on 9/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//
typealias AlertActionsCallback = (_ actions: [UIAlertAction]) -> Void

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
        let headerAction = UIAlertAction(title: item.name ?? "file", style: .default, handler: {_ in
            
        })
        headerAction.isEnabled = false
        
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
                    self?.presentAlertSheet(with: [headerAction] + actions, presentedBy: sender, viewController: viewController)
                }
            }
        } else if item is Item || status == .trashed {
            constractActions(with: types, for: [item]) { [weak self] actions in
                DispatchQueue.main.async { [weak self] in
                    self?.presentAlertSheet(with: [headerAction] + actions, presentedBy: sender, viewController: viewController)
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
                } else if let addToFavoritesIndex = filteredActionTypes.index(of: .addToFavorites) {
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
                } else if let removeFromFavorites = filteredActionTypes.index(of: .removeFromFavorites) {
                    filteredActionTypes.remove(at: removeFromFavorites)
                }
                
                if remoteItems.first(where: { !$0.isReadOnlyFolder }) == nil {
                    filteredActionTypes.remove(.moveToTrash)
                }
                
                if let index = filteredActionTypes.index(of: .deleteDeviceOriginal) {
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
                if let printIndex = filteredActionTypes.index(of: .print) {
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
    
    private func constractActions(with types: [ElementTypes],
                                  for items: [BaseDataSourceItem]?, sender: Any? = nil,
                                  actionsCallback: @escaping AlertActionsCallback) {
        
        var filteredTypes = types
        let langCode = Device.locale
//        if langCode != "tr" {
//            filteredTypes = types.filter({ $0 != .print }) //FE-2439 - Removing Print Option for Turkish (TR) language
//        }
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
                var action: UIAlertAction
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
                     .removeFromFaceImageAlbum,
                     .instaPick,
                     .endSharing,
                     .leaveSharing,
                     .moveToTrashShared:
                    
                    action = UIAlertAction(title: type.actionTitle(), style: .default, handler: { [weak self] _ in
                        self?.handleAction(type: type, items: currentItems)
                    })

                case .hide:
                    action = UIAlertAction(title: type.actionTitle(fileType: currentItems.first?.fileType), style: .default, handler: { [weak self] _ in
                        self?.handleAction(type: type, items: currentItems)
                    })
                    
                case .smash:
                    assertionFailure("please implement this function first")
                    action = UIAlertAction()

                case .share:
                    action = UIAlertAction(title: type.actionTitle(), style: .default, handler: { _ in
                        self.handleAction(type: type, items: currentItems, sender: sender)
                    })

                case .deleteDeviceOriginal:
                    if let itemsArray = items as? [Item] {
                        let serverObjects = itemsArray.filter({
                            !$0.isLocalItem
                        })
                        
                        action = UIAlertAction(title: TextConstants.actionSheetDeleteDeviceOriginal, style: .default, handler: { _ in
                            self.didSelectDeleteDeviceOriginal(serverObjects: serverObjects)
                        })
                        
                    } else {
                        action = UIAlertAction(title: type.actionTitle(), style: .default, handler: { _ in
                            self.handleAction(type: .deleteDeviceOriginal, items: currentItems)
                        })
                    }
                case .sync, .syncInProgress, .undetermend:
                    action = UIAlertAction()
                }
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
    
    private func presentAlertSheet(with actions: [UIAlertAction], presentedBy sender: Any?, onSourceView sourceView: UIView? = nil, viewController: UIViewController? = nil) {
        let vc: UIViewController
        
        if let unwrapedVC = viewController {
            vc = unwrapedVC
            
        } else {
            guard let rootVC = RouterVC().getViewControllerForPresent() else {
                return
            }
            vc = rootVC
        }
        
        
        let cancellAction = UIAlertAction(title: TextConstants.actionSheetCancel, style: .cancel, handler: { _ in
            
        })
        let actionsWithCancell = actions + [cancellAction]
        
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionsWithCancell.forEach({ actionSheetVC.addAction($0) })
        actionSheetVC.view.tintColor = UIColor.black
        
        actionSheetVC.popoverPresentationController?.sourceView = vc.view
        
        if let pressedBarButton = sender as? UIButton {
            var sourceRectFrame = pressedBarButton.convert(pressedBarButton.frame, to: vc.view)
            if sourceRectFrame.origin.x > vc.view.bounds.width {
                sourceRectFrame = CGRect(origin: CGPoint(x: pressedBarButton.frame.origin.x, y: pressedBarButton.frame.origin.y + 20), size: pressedBarButton.frame.size)
            }
            
            actionSheetVC.popoverPresentationController?.sourceRect = sourceRectFrame
        } else if let _ = sender as? UIBarButtonItem {
            //FIXME: use actionSheetVC.popoverPresentationController?.barButtonItem instead
            if vc.navigationController?.navigationBar.isTranslucent == true {
                var frame = rightButtonBox
                frame.origin.y = 44
                actionSheetVC.popoverPresentationController?.sourceRect = frame
            } else {
                actionSheetVC.popoverPresentationController?.sourceRect = rightButtonBox
            }
            
            actionSheetVC.popoverPresentationController?.permittedArrowDirections = .up 
        }
        vc.present(actionSheetVC, animated: true, completion: {})
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
            interactor.restore(items: items)
            
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
            
        case .rename:
            interactor.info(item: items, isRenameMode: true)
            
        case .delete:
            let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
            if items.count <= allowedNumberLimit {
                interactor.delete(items: items)
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
