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
            case .delete:
                itemTupple.append(EditinglBar.PreDetermendTypes.delete)
            case .download:
                itemTupple.append(EditinglBar.PreDetermendTypes.download)
            case .downloadDocument:
                itemTupple.append(EditinglBar.PreDetermendTypes.downloadDocument)
            case .info:
                itemTupple.append(EditinglBar.PreDetermendTypes.info)
            case .move:
                itemTupple.append(EditinglBar.PreDetermendTypes.move)
            case .share:
                itemTupple.append(EditinglBar.PreDetermendTypes.share)
            case .privateShare:
                itemTupple.append(EditinglBar.PreDetermendTypes.privateShare)
            case .moveToTrash:
                itemTupple.append(EditinglBar.PreDetermendTypes.delete)
            case .restore:
                itemTupple.append(EditinglBar.PreDetermendTypes.restore)
            case .moveToTrashShared:
                itemTupple.append(EditinglBar.PreDetermendTypes.delete)
            default:
                break
            }
        }

        view.setupBar(tintColor: config.tintColor, style: config.style, items: itemTupple, config: config)
    }

    func setupTabBarWith(items: [BaseDataSourceItem]) {
        guard let items = items as? [WrapData] else { return }
        
        let matchesBitmasks = calculateMatchesBitmasks(from: items)
        let elementsConfig = createElementTypesArray(from: matchesBitmasks)
        let config = EditingBarConfig(elementsConfig: elementsConfig, style: .blackOpaque, tintColor: nil)
        setupConfig(withConfig: config)
    }
    
    override func dismiss(animated: Bool) {
        view.hideBar(animated: animated)
    }
    
    func dismissWithNotification() {
        dismiss(animated: true)
        NotificationCenter.default.post(name: .showPlusTabBar, object: nil)
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
        NotificationCenter.default.post(name: .hidePlusTabBar, object: nil)
        view.showBar(animated: animated, onView: shownSourceView)
    }
    
    
    /// Returns matches  bitmask value after bitwise "and" of selection
    private func calculateMatchesBitmasks(from selectedItems: [WrapData]) -> Int {
        let itemsBitmasksArray = selectedItems.compactMap { $0.privateSharePermission?.bitmask }
        guard let firstElement = itemsBitmasksArray.first else { return 0 }
        
        return Int(itemsBitmasksArray.reduce(firstElement, &))
    }

    /// Returns element types array calculated from bitmask v
    private func createElementTypesArray(from bitmask: Int) -> [ElementTypes] {
        var bitmaskValue = bitmask
        var elementTypesArray = [ElementTypes]()

        if bitmaskValue >= 512 {
            // Read acl
            bitmaskValue -= 512
        }
        
        if bitmaskValue >= 256 {
            // Write acl
            elementTypesArray.append(.privateShare)
            bitmaskValue -= 256
        }
        
        if bitmaskValue >= 128 {
            // Comment
            bitmaskValue -= 128
        }
        
        if bitmaskValue >= 64 {
            // Update
            bitmaskValue -= 64
        }
        
        if bitmaskValue >= 32 {
            // Set attribute
            bitmaskValue -= 32
        }
        
        if bitmaskValue >= 16 {
            // Delete
            elementTypesArray.append(.delete)
            bitmaskValue -= 16
        }
        
        if bitmaskValue >= 8 {
            // Create
            bitmaskValue -= 8
        }
        
        if bitmaskValue >= 4 {
            // List
            bitmaskValue -= 4
        }
        
        if bitmaskValue >= 2 {
            // Preview
            bitmaskValue -= 2
        }
        
        if bitmaskValue >= 1 {
            // Read
            elementTypesArray.append(.download)
            elementTypesArray.append(.share)
            bitmaskValue -= 1
        }

        return elementTypesArray
    }
    

    
    func bottomBarSelectedItem(index: Int, sender: UITabBarItem, config: EditingBarConfig?) {
        basePassingPresenter?.getSelectedItems { [weak self] selectedItems in
            guard let self = self,
                  let types = config?.elementsConfig else {
                    return
            }
            
            let type = types[index]
            
            switch type {
            case .moveToTrash:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .delete))
                let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
                if selectedItems.count <= allowedNumberLimit {
                    self.interactor.moveToTrash(items: selectedItems)
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
            case .downloadDocument:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .download))
                let allowedNumberLimit = NumericConstants.numberOfSelectedItemsBeforeLimits
                if selectedItems.count <= allowedNumberLimit {
                    self.basePassingPresenter?.stopModeSelected()
                    self.interactor.downloadDocument(items: selectedItems as? [WrapData])
                } else {
                    let text = String(format: TextConstants.downloadLimitAllert, allowedNumberLimit)
                    UIApplication.showErrorAlert(message: text)
                }
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
                self.interactor.originalShare(item: selectedItems, sourceRect: self.middleTabBarRect)
            case .privateShare:
                //\AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .share)) // add analytics here later?
                self.interactor.privateShare(item: selectedItems, sourceRect: self.middleTabBarRect)

            case .sync:
                self.basePassingPresenter?.stopModeSelected()
                self.interactor.sync(item: selectedItems)
            case .print:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .print))
                self.interactor.trackEvent(elementType: .print)
                self.router.showPrint(items: selectedItems)
            case .moveToTrashShared:
                self.interactor.moveToTrashShared(items: selectedItems)
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
                actionTypes = [.move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append((item.isLocalItem) ? .backUp : .addToCmeraRoll)
            case .video:
                actionTypes = [.move]
                actionTypes.append(item.favorites ? .removeFromFavorites : .addToFavorites)
                actionTypes.append((item.isLocalItem) ? .backUp : .addToCmeraRoll)
                
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
                    
                case .download:
                    action = UIAlertAction(title: TextConstants.actionSheetDownload, style: .default, handler: { _ in
                        self.interactor.download(item: currentItems)
                    })
                case .downloadDocument:
                    action = UIAlertAction(title: TextConstants.actionSheetDownload, style: .default, handler: { _ in
                        self.interactor.downloadDocument(items: currentItems)
                    })
                case .delete:
                    action = UIAlertAction(title: TextConstants.actionSheetDelete, style: .default, handler: { _ in
                        self.interactor.delete(items: currentItems)
                    })
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
                case .shareAlbum:
                    action = UIAlertAction(title: TextConstants.actionSheetShare, style: .default, handler: { _ in
                        self.interactor.shareAlbum(items: currentItems)
                    })
                case .makeAlbumCover:
                    action = UIAlertAction(title: TextConstants.actionSheetMakeAlbumCover, style: .default, handler: { _ in
                        self.interactor.makeAlbumCover(items: currentItems)
                    })
                case .backUp:
                    action = UIAlertAction(title: TextConstants.actionSheetBackUp, style: .default, handler: { _ in
                        self.interactor.backUp(items: currentItems)
                    })
                case .copy:
                    action = UIAlertAction(title: TextConstants.actionSheetCopy, style: .default, handler: { _ in
                        self.interactor.copy(item: currentItems, toPath: "")
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
        
        DispatchQueue.main.async {
            self.setupConfig(withConfig: config)
        }
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
        basePassingPresenter?.stopModeSelected()
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
