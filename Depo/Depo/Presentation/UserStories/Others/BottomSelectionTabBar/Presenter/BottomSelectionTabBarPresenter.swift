//
//  BottomSelectionTabBarBottomSelectionTabBarPresenter.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class BottomSelectionTabBarPresenter: MoreFilesActionsPresenter, BottomSelectionTabBarModuleInput, BottomSelectionTabBarViewOutput, BottomSelectionTabBarInteractorOutput {
    
    weak var view: BottomSelectionTabBarViewInput!
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
        view.setupBar(with: config)
    }

    func setupTabBarWith(items: [BaseDataSourceItem], originalConfig: EditingBarConfig) {
        let downloadIndex = originalConfig.elementsConfig.firstIndex(of: .download)
        let syncIndex = originalConfig.elementsConfig.firstIndex(of: .sync)
        let moveToTrashIndex = originalConfig.elementsConfig.firstIndex(of: .moveToTrash)
        let hideIndex = originalConfig.elementsConfig.firstIndex(of: .hide)
        
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

        if hasRemote {
            view.enableItems(at: [moveToTrashIndex, downloadIndex, hideIndex].compactMap { $0 })
        }
        
        if hasLocal {
            view.enableItems(at: [syncIndex].compactMap { $0 })
        }
        
        guard items.allSatisfy({ $0 is WrapData }) else {
            return
        }
        
        let hasReadOnlyFolders = items.first(where: { ($0 as? WrapData)?.isReadOnlyFolder == false}) == nil
        
        if hasReadOnlyFolders {
            view.disableItems(at: [moveToTrashIndex].compactMap { $0 })
        }
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
            case .edit:
                AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .edit))
                RouterVC().getViewControllerForPresent()?.showSpinner()
                self.interactor.edit(item: selectedItems, completion: {
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
                
                self.interactor.share(item: selectedItems, sourceRect: self.middleTabBarRect)
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
                self.interactor.removeAlbums(items: selectedItems)
            case .moveToTrashShared:
                self.interactor.moveToTrashShared(items: selectedItems)
            default:
                break
            }
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
        dismiss(animated: true)
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
