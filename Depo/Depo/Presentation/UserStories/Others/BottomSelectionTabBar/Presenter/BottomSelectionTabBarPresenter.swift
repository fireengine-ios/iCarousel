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
    
    let middleTabBarRect = CGRect(x: Device.winSize.width / 2 - 5, y: Device.winSize.height - 49, width: 10, height: 50)
    
    func viewIsReady() {
        guard let bottomBarInteractor = interactor as? BottomSelectionTabBarInteractorInput,
            let currentConfig = bottomBarInteractor.currentBarcongfig else {
            return
        }
        setupConfig(withConfig: currentConfig)
    }
    
    func setupConfig(withConfig config: EditingBarConfig) {
        var itemTupple = [PreDetermendType]()
        for type in config.elementsConfig {
            switch type {
            case .hide:
                itemTupple.append(EditinglBar.PreDetermendTypes.hide)
            case .unhide:
                itemTupple.append(EditinglBar.PreDetermendTypes.unhide)
            case .smash:
                itemTupple.append(EditinglBar.PreDetermendTypes.smash)
            case .delete:
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
            case .moveToTrash:
                itemTupple.append(EditinglBar.PreDetermendTypes.delete)
            case .restore:
                itemTupple.append(EditinglBar.PreDetermendTypes.restore)
            default:
                break
            }
        }

        view.setupBar(tintColor: config.tintColor, style: config.style, items: itemTupple)
    }

    func setupTabBarWith(items: [BaseDataSourceItem], originalConfig: EditingBarConfig) {
        let downloadIndex = originalConfig.elementsConfig.index(of: .download)
        let syncIndex = originalConfig.elementsConfig.index(of: .sync)
        let moveToTrashIndex = originalConfig.elementsConfig.index(of: .moveToTrash)
        let hideIndex = originalConfig.elementsConfig.index(of: .hide)
        
        let validIndexes = [downloadIndex, syncIndex, hideIndex, moveToTrashIndex].compactMap { $0 }
        
        guard !validIndexes.isEmpty else {
            return
        }
        
        view.disableItems(at: validIndexes)
        
        guard !items.isEmpty else {
            return
        }
        
        let hasLocal = items.contains(where: { $0.isLocalItem == true })
        let hasRemote = items.contains(where: { $0.isLocalItem != true })
        let hasReadOnlyFolders = items.first(where: { ($0 as? WrapData)?.isReadOnlyFolder == false}) == nil
        
        if hasRemote {
            view.enableItems(at: [moveToTrashIndex, downloadIndex, hideIndex].compactMap { $0 })
        }
        
        if hasLocal {
            view.enableItems(at: [syncIndex].compactMap { $0 })
        }
        
        if hasReadOnlyFolders {
            view.disableItems(at: [moveToTrashIndex].compactMap { $0 })
        }
    }
    
    override func dismiss(animated: Bool) {
        view.hideBar(animated: animated)
    }
    
    func dismissWithNotification() {
        dismiss(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar), object: nil)
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
        basePassingPresenter?.getSelectedItems { [weak self] selectedItems in
            guard let self = self,
                let bottomBarInteractor = self.interactor as? BottomSelectionTabBarInteractorInput,
                let types = bottomBarInteractor.currentBarcongfig?.elementsConfig else {
                    return
            }
            
            let type = types[index]
            
            switch type {
            case .hide:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .hide))
                let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
                if selectedItems.count <= allowedNumberLimit {
                    self.interactor.hide(items: selectedItems)
                } else {
                    let text = String(format: TextConstants.hideLimitAllert, allowedNumberLimit)
                    UIApplication.showErrorAlert(message: text)
                }
            case .unhide:
                //TODO: will be another task to implement analytics calls
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .unhide))
                let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
                if selectedItems.count <= allowedNumberLimit {
                    self.interactor.unhide(items: selectedItems)
                } else {
                    let isAlbums = selectedItems is [PeopleItem] || selectedItems is [ThingsItem] || selectedItems is [PlacesItem] || selectedItems is [AlbumItem]
                    let message = isAlbums ? TextConstants.unhideAlbumsPopupText : TextConstants.unhideItemsPopupText
                    UIApplication.showErrorAlert(message: message)
                }
            case .smash:
                let controller = RouterVC().getViewControllerForPresent()
                controller?.showSpinner()
                self.interactor.smash(item: selectedItems) {
                    controller?.hideSpinner()
                }
                self.basePassingPresenter?.stopModeSelected()
            case .moveToTrash:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .delete))
                let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
                if selectedItems.count <= allowedNumberLimit {
                    self.interactor.moveToTrash(item: selectedItems)
                } else {
                    let text = String(format: TextConstants.deleteLimitAllert, allowedNumberLimit)
                    UIApplication.showErrorAlert(message: text)
                }
            case .delete:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .delete))
                let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
                if selectedItems.count <= allowedNumberLimit {
                    self.interactor.delete(items: selectedItems)
                } else {
                    let text = String(format: TextConstants.deleteLimitAllert, allowedNumberLimit)
                    UIApplication.showErrorAlert(message: text)
                }
            case .restore:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .restore))
                self.interactor.restore(items: selectedItems)
            case .download:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .download))
                let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
                if selectedItems.count <= allowedNumberLimit {
                    self.basePassingPresenter?.stopModeSelected()
                    self.interactor.download(item: selectedItems)
                } else {
                    let text = String(format: TextConstants.downloadLimitAllert, allowedNumberLimit)
                    UIApplication.showErrorAlert(message: text)
                }
            case .edit:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .edit))
                RouterVC().getViewControllerForPresent()?.showSpinner()
                self.interactor.edit(item: selectedItems, complition: {
                    RouterVC().getViewControllerForPresent()?.hideSpinner()
                })
            case .info:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .info))
                if let firstSelected = selectedItems.first as? Item {
                    self.router.onInfo(object: firstSelected)
                }
                
                self.view.unselectAll()
            case .move:
                self.interactor.move(item: selectedItems, toPath: "")
            case .share:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .share))
                /// if albums are selected and in this albums not have filled album show error
                if let albumItems = selectedItems as? [AlbumItem], albumItems.first(where: { $0.allContentCount != 0 } ) == nil {
                        self.needShowErrorShareEmptyAlbums()
                        return
                }
                
                let onlyLink = selectedItems.contains(where: {
                    $0.fileType != .image && $0.fileType != .video
                })
                
                if onlyLink {
                    self.interactor.shareViaLink(item: selectedItems, sourceRect: self.middleTabBarRect)
                } else {
                    self.interactor.share(item: selectedItems, sourceRect: self.middleTabBarRect)
                }
            case .sync:
                self.basePassingPresenter?.stopModeSelected()
                self.interactor.sync(item: selectedItems)
            case .removeFromAlbum:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .delete))
                self.interactor.removeFromAlbum(items: selectedItems)
            case .removeFromFaceImageAlbum:
                self.basePassingPresenter?.stopModeSelected()
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .delete))
                if let item = self.basePassingPresenter?.getFIRParent() {
                    self.interactor.deleteFromFaceImageAlbum(items: selectedItems, item: item)
                }
            case .addToAlbum:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .addToAlbum))
                self.interactor.addToAlbum(items: selectedItems)
            case .print:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .print))
                self.interactor.trackEvent(elementType: .print)
                self.router.showPrint(items: selectedItems)
            case .removeAlbum:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .delete))
                self.interactor.moveToTrash(item: selectedItems)
            default:
                break
            }
        }
    }

    func showAlertSheet(withTypes types: [ElementTypes], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        constractActions(withTypes: types, forItem: nil) { [weak self] actions in
            self?.presentAlertSheet(withActions: actions, presentedBy: sender)
        }
    }
    
    func showAlertSheet(withItems items: [BaseDataSourceItem], presentedBy sender: Any?, onSourceView sourceView: UIView?) {
        if items.count == 0 {//TODO: FOR NOW
            return
        }
        guard let items = items as? [Item] else {
            return
        }
        constractActions(withTypes: adjastActionTypes(forItems: items), forItem: nil) { [weak self] actions in
            self?.presentAlertSheet(withActions: actions, presentedBy: sender)
        }
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
        types.append(.moveToTrash)
        
        constractActions(withTypes: types, forItem: [item]) { [weak self] actions in
            self?.presentAlertSheet(withActions: [headerAction] + actions, presentedBy: sender)
        }
    }
    
    private func adjastActionTypes(forItems items: [Item]) -> [ElementTypes] {
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
                    
                case .doc, .pdf, .txt, .ppt, .xls, .html:
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

    private func constractActions(withTypes types: [ElementTypes], forItem items: [Item]?,
                                  actionsCallback: @escaping AlertActionsCallback) {
        
        var filteredTypes = types
        let langCode = Device.locale
//        if langCode != "tr" {
//            filteredTypes = types.filter({ $0 != .print }) //FE-2439 - Removing Print Option for Turkish (TR) language
//        }
        
        basePassingPresenter?.getSelectedItems { [weak self] selectedItems in
            guard let self = self else {
                return
            }
            var tempoItems = items
            if tempoItems == nil {
                guard let wrappedArray = selectedItems as? [Item] else {
                    actionsCallback([])
                    return
                }
                tempoItems = wrappedArray
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
                        self.router.onInfo(object: currentItems.first!)
                        self.view.unselectAll()
                    })
                    
                case .edit:
                    action = UIAlertAction(title: TextConstants.actionSheetEdit, style: .default, handler: { _ in
                        RouterVC().tabBarVC?.showSpinner()
                        self.interactor.edit(item: currentItems, complition: {
                            RouterVC().tabBarVC?.hideSpinner()
                        })
                    })
                case .download:
                    action = UIAlertAction(title: TextConstants.actionSheetDownload, style: .default, handler: { _ in
                        self.interactor.download(item: currentItems)
                    })
                case .delete:
                    action = UIAlertAction(title: TextConstants.actionSheetDelete, style: .default, handler: { _ in
                        self.interactor.delete(items: currentItems)
                    })
                case .hide:
                    action = UIAlertAction(title: TextConstants.actionSheetHide, style: .default, handler: { _ in
                        self.interactor.hide(items: currentItems)
                    })
                case .smash:
                    //Currently there is no task for smash from action sheet.
                    assertionFailure("In order to use smash please implement this function")
                    action = UIAlertAction()
                case .restore:
                    action = UIAlertAction(title: TextConstants.actionSheetRestore, style: .default, handler: { _ in
                        self.interactor.restore(items: currentItems)
                    })
                case .move:
                    action = UIAlertAction(title: TextConstants.actionSheetMove, style: .default, handler: { _ in
                        self.interactor.move(item: currentItems, toPath: "")
                    })
                case .share:
                    action = UIAlertAction(title: TextConstants.actionSheetShare, style: .default, handler: { _ in
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
                        self.interactor.shareAlbum(items: currentItems)
                    })
                case .makeAlbumCover:
                    action = UIAlertAction(title: TextConstants.actionSheetMakeAlbumCover, style: .default, handler: { _ in
                        self.interactor.makeAlbumCover(items: currentItems)
                    })
                case .removeFromAlbum:
                    action = UIAlertAction(title: TextConstants.actionSheetRemoveFromAlbum, style: .default, handler: { _ in
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
                        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .addToFavorites))
                        self.interactor.addToFavorites(items: currentItems)
                    })
                case .removeFromFavorites:
                    action = UIAlertAction(title: TextConstants.actionSheetRemoveFavorites, style: .default, handler: { _ in
                        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .removeFromFavorites))
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
                    action = UIAlertAction(title: TextConstants.tabBarPrintLabel, style: .default, handler: { _ in
                        //TODO: will be implemented in the next package
                    })
                    
                default:
                    assertionFailure("👆PLEASE add your new type into switch in constractActions( method in BottomSelectionTabBarPresenter class👆")
                    action = UIAlertAction(title: "TEST", style: .default, handler: nil)
                }
                return action
            })
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
        completeAsyncOperationEnableScreen()
        view.unselectAll()
        basePassingPresenter?.operationFinished(withType: type, response: nil)
    }
    
    override func operationFailed(type: ElementTypes, message: String) {
        completeAsyncOperationEnableScreen()
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
    
    func needShowErrorShareEmptyAlbums() {
        router.showErrorShareEmptyAlbums()
    }
    
    // MARK: base presenter
    
    override func outputView() -> Waiting? {
        return view
    }
}
