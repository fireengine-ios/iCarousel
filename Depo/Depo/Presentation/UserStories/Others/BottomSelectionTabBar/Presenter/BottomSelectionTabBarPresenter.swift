//
//  BottomSelectionTabBarBottomSelectionTabBarPresenter.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BottomSelectionTabBarPresenter: MoreFilesActionsPresenter, BottomSelectionTabBarModuleInput, BottomSelectionTabBarViewOutput, BottomSelectionTabBarInteractorOutput {
    
    weak var view: BottomSelectionTabBarViewInput!
//    var interactor: BottomSelectionTabBarInteractorInput!
    var router: BottomSelectionTabBarRouterInput!
    
    let middleTabBarRect = CGRect(x: Device.winSize.width/2 - 5, y: Device.winSize.height - 49, width: 10, height: 50)
    
    func viewIsReady() {
        guard let bottomBarInteractor = interactor as? BottomSelectionTabBarInteractorInput,
            let currentConfig = bottomBarInteractor.currentBarcongfig else {
            return
        }
        setupConfig(withConfig: currentConfig)
    }
    
    func setupConfig(withConfig config: EditingBarConfig) {
        var itemTupple: [(String, String)] = []
        for type in config.elementsConfig {
            switch type {
            case .delete:
                itemTupple.append(EditinglBar.PreDetermendTypes.delete)
            case .deleteFaceImage:
                itemTupple.append(EditinglBar.PreDetermendTypes.delete)
            case .download:
                itemTupple.append(EditinglBar.PreDetermendTypes.download)
            case .edit:
                itemTupple.append(EditinglBar.PreDetermendTypes.edit)
            case .info:
                itemTupple.append(EditinglBar.PreDetermendTypes.info)
            case .move:
                itemTupple.append(EditinglBar.PreDetermendTypes.move)
            case .share:
                itemTupple.append(EditinglBar.PreDetermendTypes.share)
            case .sync:
                itemTupple.append(EditinglBar.PreDetermendTypes.sync)
            case .removeFromAlbum:
                itemTupple.append(EditinglBar.PreDetermendTypes.removeFromAlbum)
            case .removeFromFaceImageAlbum:
                itemTupple.append(EditinglBar.PreDetermendTypes.removeFromFaceImageAlbum)
            case .addToAlbum:
                itemTupple.append(EditinglBar.PreDetermendTypes.addToAlbum)
            case .makeAlbumCover:
                itemTupple.append(EditinglBar.PreDetermendTypes.makeCover)
            case .print:
                itemTupple.append(EditinglBar.PreDetermendTypes.print)
            case .removeAlbum:
                itemTupple.append(EditinglBar.PreDetermendTypes.removeAlbum)
            default:
                break
            }
        }

        view.setupBar(tintColor: config.tintColor,
                      style: config.style,
                      items: itemTupple)
    }
    
    func setupTabBarWith(items: [BaseDataSourceItem], originalConfig: EditingBarConfig) {
        if originalConfig.elementsConfig.contains(.sync), originalConfig.elementsConfig.contains(.download), originalConfig.elementsConfig.contains(.delete) {
            
            let downloadIndex = originalConfig.elementsConfig.index(of: .download)
            let syncIndex = originalConfig.elementsConfig.index(of: .sync)
            let deleteIndex = originalConfig.elementsConfig.index(of: .delete)
            
            view.disableItems(atIntdex: [downloadIndex!, syncIndex!])
//            if items.count < 1 {
//                view.disableItems(atIntdex: [downloadIndex!, syncIndex!])
//                return
//            }
            
            items.forEach({
                if $0.isLocalItem == true {
                    view.enableIems(atIndex: [syncIndex!])
                } else {
                    view.enableIems(atIndex: [downloadIndex!])
                }
            })
            if items.contains(where: { $0.isLocalItem != true }) {
                view.enableIems(atIndex: [deleteIndex!])
            } else {
                view.disableItems(atIntdex: [deleteIndex!])
            }
        }
    }
    
    override func dismiss(animated: Bool) {
        view.hideBar(animated: animated)
    }
    
    func show(animated: Bool, onView sourceView: UIView?) {
        let router = RouterVC()
        guard let rootVC = router.rootViewController else {
            return
        }
        var shownSourceView: UIView
        if let newSourceView = sourceView {
            shownSourceView = newSourceView
        } else {
            if let tabBarViewController = rootVC as? TabBarViewController {
                shownSourceView = tabBarViewController.mainContentView
            } else {
                shownSourceView = rootVC.view
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationHidePlusTabBar), object: nil)
        view.showBar(animated: animated, onView: shownSourceView)
    }
    
    func bottomBarSelectedItem(index: Int, sender: UITabBarItem) {
        guard let selectedItems = basePassingPresenter?.selectedItems else {
            return
        }
        
        guard let bottomBarInteractor = interactor as? BottomSelectionTabBarInteractorInput,
            let types = bottomBarInteractor.currentBarcongfig?.elementsConfig else {
            return
        }
        
        let type = types[index]
        
        switch type {
        case .delete:
            MenloworksAppEvents.onDeleteClicked()
            interactor.delete(item: selectedItems)
            basePassingPresenter?.stopModeSelected()
        case .deleteFaceImage:
            basePassingPresenter?.stopModeSelected()
            basePassingPresenter?.deleteFromFaceImageAlbum(items: selectedItems)
        case .download:
            MenloworksAppEvents.onDownloadClicked()
            basePassingPresenter?.stopModeSelected()
            interactor.download(item: selectedItems)
        case .edit:
            MenloworksTagsService.shared.onEditClicked()
            RouterVC().getViewControllerForPresent()?.showSpiner()
            self.interactor.edit(item: selectedItems, complition: {
                RouterVC().getViewControllerForPresent()?.hideSpiner()
            })
        case .info:
            if let firstSelected = selectedItems.first as? Item {
                router.onInfo(object: firstSelected)
            }
            
            view.unselectAll()
        case .move:
            interactor.move(item: selectedItems, toPath: "")
        case .share:
            let onlyLink = selectedItems.contains(where: {
                $0.fileType != .image && $0.fileType != .video
            })

            if onlyLink {
                interactor.shareViaLink(item: selectedItems, sourceRect: middleTabBarRect)
            } else {
                interactor.share(item: selectedItems, sourceRect: middleTabBarRect)
            }
            basePassingPresenter?.stopModeSelected()
        case .sync:
            MenloworksAppEvents.onSyncClicked()
            basePassingPresenter?.stopModeSelected()
            interactor.sync(item: selectedItems)
        case .removeFromAlbum:
            MenloworksAppEvents.onRemoveFromAlbumClicked()
            interactor.removeFromAlbum(items: selectedItems)
            basePassingPresenter?.stopModeSelected()
        case .removeFromFaceImageAlbum:
            self.basePassingPresenter?.stopModeSelected()
            basePassingPresenter?.deleteFromFaceImageAlbum(items: selectedItems)
        case .addToAlbum:
            interactor.addToAlbum(items: selectedItems)
        case .print:
            MenloworksAppEvents.onPrintClicked()
            router.showPrint(items: selectedItems)
        case .removeAlbum:
            interactor.delete(item: selectedItems)
        default:
            break
        }
    }

    func showAlertSheet(withTypes types: [ElementTypes], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        presentAlertSheet(withActions: constractActions(withTypes: types, forItem: nil), presentedBy: sender)
    }
    
    func showAlertSheet(withItems items: [BaseDataSourceItem], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        if items.count == 0 {//TODO: FOR NOW
            return
        }
        guard let items = items as? [Item] else {
            return
        }
        let actions = constractActions(withTypes: adjastActionTypes(forItems: items), forItem: nil)
        presentAlertSheet(withActions: actions, presentedBy: sender)
    }
    
    func showSpecifiedAlertSheet(withItem item: BaseDataSourceItem, presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        
        let headerAction = UIAlertAction(title: item.name ?? "file", style: .default, handler: {_ in
            
        })
        headerAction.isEnabled = false
        
        var types: [ElementTypes] = [.info, .share, .move]
        
        guard let item = item as? Item else {
            return
        }
        types.append(item.favorites ? .removeFromFavorites : .addToFavorites)
        types.append(.delete)
        
        let actions = constractActions(withTypes: types, forItem: [item])
        
        presentAlertSheet(withActions: [headerAction] + actions, presentedBy: sender)
    }
    
    private func adjastActionTypes(forItems items: [Item]) -> [ElementTypes] {
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

    private func constractActions(withTypes types: [ElementTypes], forItem items: [Item]?) -> [UIAlertAction] {
        
        var filteredTypes = types
        let langCode = Device.locale
        if langCode != "tr", langCode != "en" {
            filteredTypes = types.filter({ $0 != .print })
        }
        
        var tempoItems = items
        if tempoItems == nil {
            guard let wrappedArray = basePassingPresenter?.selectedItems as? [Item] else {
                return []
            }
            tempoItems = wrappedArray
        }
        
        guard let currentItems = tempoItems else {
            return []
        }
        return filteredTypes.map {
            var action: UIAlertAction
            switch $0 {
            case .info:
                action = UIAlertAction(title: TextConstants.actionSheetInfo, style: .default, handler: { _ in
                    self.router.onInfo(object: currentItems.first!)
                    self.view.unselectAll()
                })
                
            case .edit:
                action = UIAlertAction(title: TextConstants.actionSheetEdit, style: .default, handler: { _ in
                    RouterVC().tabBarVC?.showSpiner()
                    self.interactor.edit(item: currentItems, complition: {
                        RouterVC().tabBarVC?.hideSpiner()
                    })
                })
            case .download:
                action = UIAlertAction(title: TextConstants.actionSheetDownload, style: .default, handler: { _ in
                    MenloworksAppEvents.onDownloadClicked()
                    self.interactor.download(item: currentItems)
                })
            case .delete:
                action = UIAlertAction(title: TextConstants.actionSheetDelete, style: .default, handler: { _ in
                    MenloworksAppEvents.onDeleteClicked()
                    self.interactor.delete(item: currentItems)
                })
            case .deleteFaceImage:
                action = UIAlertAction(title: TextConstants.actionSheetDelete, style: .default, handler: { _ in
                    self.basePassingPresenter?.deleteFromFaceImageAlbum(items: currentItems)
                })
            case .move:
                action = UIAlertAction(title: TextConstants.actionSheetMove, style: .default, handler: { _ in
                    self.interactor.move(item: currentItems, toPath: "")
                })
            case .share:
                action = UIAlertAction(title: TextConstants.actionSheetShare, style: .default, handler: { _ in
                    MenloworksAppEvents.onShareClicked()
                    self.interactor.share(item: currentItems, sourceRect: self.middleTabBarRect)
                })
            //Photos and albumbs
            case .photos:
                action = UIAlertAction(title: TextConstants.actionSheetPhotos, style: .default, handler: { _ in
                    self.interactor.photos(items: currentItems)
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
                    MenloworksAppEvents.onRemoveFromAlbumClicked()
                    self.interactor.removeFromAlbum(items: currentItems)
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
                    self.interactor.createStory(items: currentItems)
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
                    self.interactor.addToFavorites(items: currentItems)
                })
            case .removeFromFavorites:
                action = UIAlertAction(title: TextConstants.actionSheetRemoveFavorites, style: .default, handler: { _ in
                    
                    self.interactor.removeFromFavorites(items: currentItems)
                })
            case .documentDetails:
                action = UIAlertAction(title: TextConstants.actionSheetDocumentDetails, style: .default, handler: { _ in
                    self.interactor.documentDetails(items: currentItems)
                })
                
            case .select:
                action = UIAlertAction(title: TextConstants.actionSheetSelect, style: .default, handler: { _ in
//                    self.interactor.//TODO: select and select all pass to grid's presenter
                })
            case .selectAll:
                action = UIAlertAction(title: TextConstants.actionSheetSelectAll, style: .default, handler: { _ in
//                    self.interactor.selectAll(items: <#T##[Item]#>)??? //TODO: select and select all pass to grid's presenter
                })
            case .print:
                    action = UIAlertAction(title: "Print", style: .default, handler: { _ in
                        MenloworksAppEvents.onPrintClicked()
                      //TODO: will be implemented in the next package
                    })

            default:
                action = UIAlertAction(title: "TEST", style: .default, handler: { _ in
                    
                })
            }
            return action
        }
    }
    
    private func presentAlertSheet(withActions actions: [UIAlertAction], presentedBy sender: Any?, onSourceView sourceView: UIView? = nil) {
        let routerVC = RouterVC()
        guard let rootVC = routerVC.rootViewController else {
            return
        }
        let cancellAction = UIAlertAction(title: TextConstants.actionSheetCancel, style: .cancel, handler: { _ in
            
        })
        let actionsWithCancell: [UIAlertAction] = actions + [cancellAction]
        
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionsWithCancell.forEach({ actionSheetVC.addAction($0) })

        actionSheetVC.popoverPresentationController?.sourceView = rootVC.view

        if let pressedBarButton = sender as? UIButton {
            var sourceRectFrame = pressedBarButton.convert(pressedBarButton.frame, to: rootVC.view)
            if sourceRectFrame.origin.x > rootVC.view.bounds.size.width {
                sourceRectFrame = CGRect(origin: CGPoint(x: pressedBarButton.frame.origin.x, y: pressedBarButton.frame.origin.y + 20), size: pressedBarButton.frame.size)
            }
            
            actionSheetVC.popoverPresentationController?.sourceRect = sourceRectFrame
        }
        rootVC.present(actionSheetVC, animated: true, completion: {})
    }
    
    func setupTabBarWith(config: EditingBarConfig) {
        guard var bottomBarInteractor = interactor as? BottomSelectionTabBarInteractorInput else {
            return
        }
        bottomBarInteractor.currentBarcongfig = config
        setupConfig(withConfig: config)
    }
    
    
    // MARK: - Interactor output
    
    override func operationFinished(type: ElementTypes) {
        compliteAsyncOperationEnableScreen()
        view.unselectAll()
        basePassingPresenter?.operationFinished(withType: type, response: nil)
    }
    
    override func operationFailed(type: ElementTypes, message: String) {
        compliteAsyncOperationEnableScreen()
        view.unselectAll()
        basePassingPresenter?.operationFailed(withType: type)
        UIApplication.showErrorAlert(message: message)
    }
    
    override func operationStarted(type: ElementTypes) {
        startAsyncOperationDisableScreen()
    }
    
    func selectFolder(_ selectFolder: SelectFolderViewController) {
        router.showSelectFolder(selectFolder: selectFolder)
    }
    
    func objectsToShare(rect: CGRect?, urls: [String]) {
        router.showShare(rect: rect, urls: urls)
    }
    
    func deleteMusic(_ completion: @escaping VoidHandler) {
        router.showDeleteMusic(completion)
    }
    
    // MARK: base presenter
    
    override func outputView() -> Waiting? {
        return view
    }
}
