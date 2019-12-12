//
//  PhotoVideoDetailPhotoVideoDetailPresenter.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhotoVideoDetailPresenter: BasePresenter, PhotoVideoDetailModuleInput, PhotoVideoDetailViewOutput, PhotoVideoDetailInteractorOutput {
    
    weak var view: PhotoVideoDetailViewInput!
    var interactor: PhotoVideoDetailInteractorInput!
    var router: PhotoVideoDetailRouterInput!

    weak var bottomBarPresenter: BottomSelectionTabBarModuleInput?
    var alertSheetModule: AlertFilesActionsSheetModuleInput?
    
    var alertSheetExcludeTypes = [ElementTypes]()
    
    var item: Item?
    
    func viewIsReady(view: UIView) {
        interactor.onViewIsReady()
        bottomBarPresenter?.show(animated: false, onView: view)
    }
    
    func videoStarted() {
        interactor.trackVideoStart()
    }
    
    func videoStoped() {
        interactor.trackVideoStop()
    }
    
    func prepareBarConfigForFileTypes(fileTypes: [FileType], selectedIndex: Int) -> EditingBarConfig {
        
        var barConfig = interactor.bottomBarConfig(for: selectedIndex)
        var actionTypes = barConfig.elementsConfig
        
        if !fileTypes.contains(.image) {
            if let editIndex = actionTypes.index(of: .edit) {
                actionTypes.remove(at: editIndex)
            }
            if let printIndex = actionTypes.index(of: .print) {
                actionTypes.remove(at: printIndex)
            }
//            if fileTypes.contains(.video), let infoIndex = actionTypes.index(of: .info) {
//                actionTypes.remove(at: infoIndex)
//            }
            barConfig = EditingBarConfig(elementsConfig: actionTypes,
                                         style: barConfig.style,
                                         tintColor: barConfig.tintColor)
        }
        return barConfig
    }
    
    func onShowSelectedItem(at index: Int, from items: [Item]) {
        view.onShowSelectedItem(at: index, from: items)
        getSelectedItems { [weak self] selectedItems in
            guard let self = self else {
                return
            }
            let allSelectedItemsTypes = selectedItems.map { $0.fileType }
            
            let barConfig = self.prepareBarConfigForFileTypes(fileTypes: allSelectedItemsTypes, selectedIndex: index)
            self.bottomBarPresenter?.setupTabBarWith(config: barConfig)
            self.view.onItemSelected(at: index, from: items)
        }
    }
    
    func setSelectedItemIndex(selectedIndex: Int) {
        if interactor.allItems.isEmpty {
            return
        }
        
        view.onItemSelected(at: selectedIndex, from: interactor.allItems)
        
        let selectedItems = [interactor.allItems[selectedIndex]]
        let allSelectedItemsTypes = selectedItems.map { $0.fileType }
        
        let barConfig = prepareBarConfigForFileTypes(fileTypes: allSelectedItemsTypes, selectedIndex: selectedIndex)
        bottomBarPresenter?.setupTabBarWith(config: barConfig)
        interactor.currentItemIndex = selectedIndex
    }
    
    func updateBars() {
        if interactor.allItems.isEmpty {
            return
        }
        
        view.onItemSelected(at: interactor.currentItemIndex, from: interactor.allItems)
        
        let selectedItems = [interactor.allItems[interactor.currentItemIndex]]
        let allSelectedItemsTypes = selectedItems.map { $0.fileType }
        
        let barConfig = prepareBarConfigForFileTypes(fileTypes: allSelectedItemsTypes, selectedIndex: interactor.currentItemIndex)
        bottomBarPresenter?.setupTabBarWith(config: barConfig)
    }
    
    func onInfo(object: Item) {
        router.onInfo(object: object)
    }
    
    func viewWillDisappear() {
        bottomBarPresenter?.dismiss(animated: false)
    }
    
    func viewFullyLoaded() {
//        bottomBarPresenter?.show(animated: false, onView: self.view)
    }
    
    func startCreatingAVAsset() {
        startAsyncOperation()
    }
    
    func stopCreatingAVAsset() {
        asyncOperationSuccess()
    }

    func moreButtonPressed(sender: Any?, inAlbumState: Bool, object: Item, selectedIndex: Int) {
        //let currentItem = interactor.allItems[interactor.currentItemIndex]
        var actions = [ElementTypes]()
        
        switch object.fileType {
        case .audio, .video, .image:
            actions = interactor.setupedMoreMenuConfig//ActionSheetPredetermendConfigs.photoVideoDetailActions
        case .allDocs:
            actions = ActionSheetPredetermendConfigs.documetsDetailActions
        default:
            break
        }
        alertSheetModule?.showAlertSheet(with: actions,
                                         items: [object],
                                         presentedBy: sender,
                                         onSourceView: nil,
                                         excludeTypes: alertSheetExcludeTypes)
    }
    
    func replaceUploaded(_ item: WrapData) {
        interactor.replaceUploaded(item)
    }
    
    
    // MARK: presenter output
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        let currentItem = interactor.allItems[interactor.currentItemIndex]
        selectedItemsCallback([currentItem])
    }
    

    func operationFinished(withType type: ElementTypes, response: Any?) {
        switch type {
        case .delete, .removeFromAlbum, .removeFromFaceImageAlbum:
            outputView()?.hideSpinner()
            interactor.deleteSelectedItem(type: type)
        case .removeFromFavorites, .addToFavorites:
            interactor.onViewIsReady()
        case .hide:
            //TODO: FE-1865
            return
        default:
            break
        }
        
    }
    
    func operationFailed(withType type: ElementTypes) {
        outputView()?.hideSpinner()

        debugPrint("failed")
    }
    
    func goBack() {
        view.hideView()
    }
    
    func updateItems(objects: [Item], selectedIndex: Int, isRightSwipe: Bool) {
        view.updateItems(objectsArray: objects, selectedIndex: selectedIndex, isRightSwipe: isRightSwipe)
    }
    
    func selectModeSelected() {
        
    }
    
    func selectAllModeSelected() {
        
    }
    
    func changeCover() { 
    
    }
    
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) {
        if let item = item,
            let id = item.id {            
            if item is PeopleItem {
                interactor.deletePhotosFromPeopleAlbum(items: items, id: id)
            } else if item is ThingsItem {
                interactor.deletePhotosFromThingsAlbum(items: items, id: id)
            } else if item is PlacesItem {
                interactor.deletePhotosFromPlacesAlbum(items: items, uuid: RouterVC().getParentUUID())
            }
        }
    }
    
    func openInstaPick() { }
    
    func deSelectAll() {
        
    }
    
    func didRemoveFromAlbum(completion: @escaping (() -> Void)) {
        router.showRemoveFromAlbum(completion: completion)
    }
    
    func printSelected() { }
    func stopModeSelected() { }
    
    override func startAsyncOperation() {
        outputView()?.showSpinner()
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}
