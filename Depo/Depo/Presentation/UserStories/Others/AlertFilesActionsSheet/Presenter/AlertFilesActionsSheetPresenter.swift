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
        constractSpecifiedActions(with: types, for: items) {[weak self] (actions) in
            DispatchQueue.main.async { [weak self] in
                self?.presentAlertSheet(with: actions, presentedBy: sender)
            }
        }
        
    }
    
    func showSpecifiedAlertSheet(with item: BaseDataSourceItem, presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController? = nil) {
        let headerAction = UIAlertAction(title: item.name ?? "file", style: .default, handler: {_ in
            
        })
        headerAction.isEnabled = false
        
        guard let item = item as? Item else {
            return
        }
        
        if item.fileType == .photoAlbum {
            let types: [ElementTypes] = [.shareAlbum, .download, .completelyDeleteAlbums, .removeAlbum, .albumDetails]
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
        } else if item.fileType.isFaceImageType || item.fileType.isFaceImageAlbum {
            let types: [ElementTypes] = [.shareAlbum, .albumDetails, .download]
            
            constractActions(with: types, for: [item]) { [weak self] actions in
                DispatchQueue.main.async { [weak self] in
                    self?.presentAlertSheet(with: [headerAction] + actions, presentedBy: sender, viewController: viewController)
                }
            }
        } else {
            var types: [ElementTypes] = [.info, .share, .move]
            
            types.append(item.favorites ? .removeFromFavorites : .addToFavorites)
            types.append(.delete)
            
            if item.fileType == .image || item.fileType == .video {
                types.append(.download)
            }
            
            constractActions(with: types, for: [item], sender: sender) { [weak self] actions in
                DispatchQueue.main.async { [weak self] in
                    self?.presentAlertSheet(with: [headerAction] + actions, presentedBy: sender, viewController: viewController)
                }
            }
        }
    }
    
    func showSpecifiedMusicAlertSheet(with item: WrapData, presentedBy sender: Any?, onSourceView sourceView: UIView?, viewController: UIViewController?) {
        var types: [ElementTypes] = []
        
        types.append(item.favorites ? .removeFromFavorites : .addToFavorites)
        
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
                actionTypes.append(.delete)
                
            case .folder:
                break
            case .image:
                actionTypes = [.createStory, .move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append((item.albums != nil) ? .removeFromAlbum : .addToAlbum)
                actionTypes.append((item.isLocalItem) ? .backUp : .addToCmeraRoll)
                if !item.isLocalItem {
                    actionTypes.append(.delete)
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
                    actionTypes.append(.delete)
                    
                case .doc, .pdf, .txt, .ppt, .xls, .html:
                    actionTypes = [.move, .copy, .documentDetails]
                    actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                    actionTypes.append(.delete)
                    
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
                    filteredActionTypes.append(.addToFavorites)
                } else if let addToFavoritesIndex = filteredActionTypes.index(of: .addToFavorites) {
                    filteredActionTypes.remove(at: addToFavoritesIndex)
                }
                
                if remoteItems.contains(where: { $0.favorites }) {
                    filteredActionTypes.append(.removeFromFavorites)
                } else if let removeFromFavorites = filteredActionTypes.index(of: .removeFromFavorites) {
                    filteredActionTypes.remove(at: removeFromFavorites)
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
        if langCode != "tr", langCode != "en" {
            filteredTypes = types.filter({ $0 != .print })
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
            actionsCallback(filteredTypes.map {
                var action: UIAlertAction
                switch $0 {
                case .info:
                    action = UIAlertAction(title: TextConstants.actionSheetInfo, style: .default, handler: { _ in
                        self.interactor.info(item: currentItems, isRenameMode: false)
                        //                    self.view.unselectAll()
                    })
                case .edit:
                    action = UIAlertAction(title: TextConstants.actionSheetEdit, style: .default, handler: { _ in
                        UIApplication.topController()?.showSpinner()
                        self.interactor.edit(item: currentItems, complition: {
                            UIApplication.topController()?.hideSpinner()
                        })
                    })
                case .download:
                    action = UIAlertAction(title: TextConstants.actionSheetDownload, style: .default, handler: { _ in
                        MenloworksAppEvents.onDownloadClicked()
                        
                        let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
                        if currentItems.count <= allowedNumberLimit {
                            self.interactor.download(item: currentItems)
                            self.basePassingPresenter?.stopModeSelected()
                        } else {
                            let text = String(format: TextConstants.downloadLimitAllert, allowedNumberLimit)
                            UIApplication.showErrorAlert(message: text)
                        }
                    })
                case .delete:
                    action = UIAlertAction(title: TextConstants.actionSheetDelete, style: .default, handler: { _ in
                        MenloworksAppEvents.onDeleteClicked()
                        
                        let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
                        if currentItems.count <= allowedNumberLimit {
                            self.interactor.delete(item: currentItems)
                            self.basePassingPresenter?.stopModeSelected()
                        } else {
                            let text = String(format: TextConstants.deleteLimitAllert, allowedNumberLimit)
                            UIApplication.showErrorAlert(message: text)
                        }
                    })
                case .move:
                    action = UIAlertAction(title: TextConstants.actionSheetMove, style: .default, handler: { _ in
                        self.interactor.move(item: currentItems, toPath: "")
                    })
                case .share:
                    action = UIAlertAction(title: TextConstants.actionSheetShare, style: .default, handler: { _ in
                        MenloworksAppEvents.onShareClicked()
                        self.interactor.share(item: currentItems, sourceRect: self.getSourceRect(sender: sender, controller: nil))
                    })
                //Photos and albumbs
                case .photos:
                    action = UIAlertAction(title: TextConstants.actionSheetPhotos, style: .default, handler: { _ in
                        self.interactor.photos(items: currentItems)
                    })
                case .createAlbum:
                    action = UIAlertAction(title: TextConstants.actionSheetAddToAlbum, style: .default, handler: { _ in
                        debugPrint("Can not create album for now")
                    })
                case .addToAlbum:
                    action = UIAlertAction(title: TextConstants.actionSheetAddToAlbum, style: .default, handler: { _ in
                        self.interactor.addToAlbum(items: currentItems)
                    })
                case .albumDetails:
                    action = UIAlertAction(title: TextConstants.actionSheetAlbumDetails, style: .default, handler: { _ in
                        self.interactor.albumDetails(items: currentItems)
                    })
                case .shareAlbum:
                    action = UIAlertAction(title: TextConstants.actionSheetShare, style: .default, handler: { _ in
                        MenloworksAppEvents.onShareClicked()
                        self.interactor.shareAlbum(items: currentItems)
                    })
                case .makeAlbumCover:
                    action = UIAlertAction(title: TextConstants.actionSheetMakeAlbumCover, style: .default, handler: { _ in
                        self.interactor.makeAlbumCover(items: currentItems)
                    })
                case .removeFromAlbum:
                    action = UIAlertAction(title: TextConstants.actionSheetRemoveFromAlbum, style: .default, handler: { _ in
                        MenloworksTagsService.shared.onRemoveFromAlbumClicked()
                        MenloworksEventsService.shared.onRemoveFromAlbumClicked()
                        self.interactor.removeFromAlbum(items: currentItems)
                        self.basePassingPresenter?.stopModeSelected()
                    })
                case .backUp:
                    action = UIAlertAction(title: TextConstants.actionSheetBackUp, style: .default, handler: { _ in
                        
                        self.interactor.backUp(items: currentItems)
                    })
                case .copy:
                    action = UIAlertAction(title: TextConstants.actionSheetCopy, style: .default, handler: { _ in
                        self.interactor.copy(item: currentItems, toPath: "")
                    })
                case .createStory:
                    action = UIAlertAction(title: TextConstants.actionSheetCreateStory, style: .default, handler: { _ in
                        let images = currentItems.filter({ $0.fileType == .image })
                        if images.count <= NumericConstants.maxNumberPhotosInStory {
                            self.interactor.createStory(items: images)
                            self.basePassingPresenter?.stopModeSelected()
                        } else {
                            let text = String(format: TextConstants.createStoryPhotosMaxCountAllert, NumericConstants.maxNumberPhotosInStory)
                            UIApplication.showErrorAlert(message: text)
                        }
                    })
                case .iCloudDrive:
                    action = UIAlertAction(title: TextConstants.actionSheetiCloudDrive, style: .default, handler: { _ in
                        self.interactor.iCloudDrive(items: currentItems)
                    })
                case .lifeBox:
                    action = UIAlertAction(title: TextConstants.actionSheetLifeBox, style: .default, handler: { _ in
                        self.interactor.lifeBox(items: currentItems)
                    })
                case .more:
                    action = UIAlertAction(title: TextConstants.actionSheetMore, style: .default, handler: { _ in
                        self.interactor.more(items: currentItems)
                    })
                case .musicDetails:
                    action = UIAlertAction(title: TextConstants.actionSheetMusicDetails, style: .default, handler: { _ in
                        self.interactor.musicDetails(items: currentItems)
                    })
                case .addToPlaylist:
                    action = UIAlertAction(title: TextConstants.actionSheetAddToPlaylist, style: .default, handler: { _ in
                        self.interactor.addToPlaylist(items: currentItems)
                    })
                case .addToCmeraRoll:
                    action = UIAlertAction(title: TextConstants.actionSheetDownloadToCameraRoll, style: .default, handler: { _ in
                        self.interactor.downloadToCmeraRoll(items: currentItems)
                    })
                case .addToFavorites:
                    action = UIAlertAction(title: TextConstants.actionSheetAddToFavorites, style: .default, handler: { _ in
                        MenloworksEventsService.shared.onAddToFavoritesClicked()
                        MenloworksTagsService.shared.onFavoritesOpen()
                        self.basePassingPresenter?.stopModeSelected()
                        self.interactor.addToFavorites(items: currentItems)
                    })
                case .removeFromFavorites:
                    action = UIAlertAction(title: TextConstants.actionSheetRemoveFavorites, style: .default, handler: { _ in
                        self.interactor.removeFromFavorites(items: currentItems)
                        self.basePassingPresenter?.stopModeSelected()
                    })
                case .documentDetails:
                    action = UIAlertAction(title: TextConstants.actionSheetDocumentDetails, style: .default, handler: { _ in
                        self.interactor.documentDetails(items: currentItems)
                    })
                    
                case .select:
                    action = UIAlertAction(title: TextConstants.actionSheetSelect, style: .default, handler: { _ in
                        self.basePassingPresenter?.selectModeSelected()
                        //                    self.interactor.//TODO: select and select all pass to grid's presenter
                    })
                case .selectAll:
                    action = UIAlertAction(title: TextConstants.actionSheetSelectAll, style: .default, handler: { _ in
                        self.basePassingPresenter?.selectAllModeSelected()
                        //                    self.interactor.selectAll(items: <#T##[Item]#>)??? //TODO: select and select all pass to grid's presenter
                    })
                case .deSelectAll:
                    action = UIAlertAction(title: TextConstants.actionSheetDeSelectAll, style: .default, handler: { _ in
                        self.basePassingPresenter?.deSelectAll()
                    })
                case .print:
                    action = UIAlertAction(title: TextConstants.tabBarPrintLabel, style: .default, handler: { _ in
                        MenloworksAppEvents.onPrintClicked()
                        self.basePassingPresenter?.printSelected()
                    })
                case .rename:
                    action = UIAlertAction(title: TextConstants.actionSheetRename, style: .default, handler: { _ in
                        self.interactor.info(item: currentItems, isRenameMode: true)
                    })
                case .completelyDeleteAlbums:
                    action = UIAlertAction(title: TextConstants.actionSheetDelete, style: .default, handler: { _ in
                        MenloworksAppEvents.onDeleteClicked()
                        self.interactor.completelyDelete(albums: currentItems)
                    })
                case .removeAlbum:
                    action = UIAlertAction(title: TextConstants.actionSheetRemove, style: .default, handler: { _ in
                        self.interactor.delete(item: currentItems)
                    })
                case .deleteDeviceOriginal:
                    if let itemsArray = items as? [Item] {
                        let serverObjects = itemsArray.filter({
                            !$0.isLocalItem
                        })
                        
                        action = UIAlertAction(title: "", style: .default, handler: nil)
                        MediaItemOperationsService.shared.getLocalDuplicates(remoteItems: serverObjects, duplicatesCallBack: { [weak self] items in
                            let localDuplicates = items
                            action = UIAlertAction(title: TextConstants.actionSheetDeleteDeviceOriginal, style: .default, handler: { _ in
                                MenloworksAppEvents.onDeleteClicked()
                                self?.interactor.deleteDeviceOriginal(items: localDuplicates)
                            })
                            self?.semaphore.signal()
                        })
                        self.semaphore.wait()
                        
                    } else {
                        action = UIAlertAction(title: TextConstants.actionSheetDeleteDeviceOriginal, style: .default, handler: { _ in
                            MenloworksAppEvents.onDeleteClicked()
                            self.interactor.deleteDeviceOriginal(items: currentItems)
                        })
                    }
                case .sync:
                    action = UIAlertAction()
                case .undetermend:
                    action = UIAlertAction()
                case .changeCoverPhoto:
                    action = UIAlertAction(title: TextConstants.actionSheetChangeCover, style: .default, handler: { _ in
                        self.basePassingPresenter?.changeCover()
                    })
                case .removeFromFaceImageAlbum:
                    action = UIAlertAction(title: TextConstants.actionSheetRemoveFromAlbum, style: .default, handler: { _ in
                        self.basePassingPresenter?.stopModeSelected()
                        self.basePassingPresenter?.deleteFromFaceImageAlbum(items: currentItems)
                    })
                case .deleteFaceImage:
                    action = UIAlertAction(title: TextConstants.actionSheetDelete, style: .default, handler: { _ in
                        MenloworksAppEvents.onDeleteClicked()
                        self.interactor.delete(item: currentItems)
                        self.basePassingPresenter?.stopModeSelected()
                    })
                case .instaPick:
                    action = UIAlertAction(title: TextConstants.newInstaPick, style: .default, handler: { _ in
                        self.basePassingPresenter?.openInstaPick()
                    })
                }
                return action
            })
        }
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
}
