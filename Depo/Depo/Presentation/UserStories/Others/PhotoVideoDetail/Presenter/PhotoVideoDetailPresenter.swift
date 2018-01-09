//
//  PhotoVideoDetailPhotoVideoDetailPresenter.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class PhotoVideoDetailPresenter: BasePresenter, PhotoVideoDetailModuleInput, PhotoVideoDetailViewOutput, PhotoVideoDetailInteractorOutput {

    typealias Item = WrapData
    
    weak var view: PhotoVideoDetailViewInput!
    var interactor: PhotoVideoDetailInteractorInput!
    var router: PhotoVideoDetailRouterInput!

    weak var bottomBarPresenter: BottomSelectionTabBarModuleInput?
    weak var alertSheetModule: AlertFilesActionsSheetModuleInput?
    
    var alertSheetExcludeTypes = [ElementTypes]()
    
    func viewIsReady(view: UIView) {
        interactor.onViewIsReady()
        bottomBarPresenter?.show(animated: false, onView: view)
    }
    
    func onShowSelectedItem(at index: Int, from items:[Item]) {
        view.onShowSelectedItem(at: index, from: items)

        let allSelectedItemsTypes = selectedItems.map{return $0.fileType}
        
        var barConfig = interactor.bottomBarConfig
        var actionTypes = barConfig.elementsConfig
        
        if !allSelectedItemsTypes.contains(.image) {
            if let editIndex = actionTypes.index(of: .edit) {
                actionTypes.remove(at: editIndex)
            }
            if let printIndex = actionTypes.index(of: .print) {
                actionTypes.remove(at: printIndex)
            }
            if allSelectedItemsTypes.contains(.video), let infoIndex = actionTypes.index(of: .info) {
                actionTypes.remove(at: infoIndex)
            }
            barConfig = EditingBarConfig(elementsConfig: actionTypes,
                                         style: barConfig.style,
                                         tintColor: barConfig.tintColor)
        }
        
        bottomBarPresenter?.setupTabBarWith(config: barConfig)
        view.onItemSelected(at: index, from: items)
    }
    
    func setSelectedItemIndex(selectedIndex: Int) {
        interactor.setSelectedItemIndex(selectedIndex: selectedIndex)
        view.onItemSelected(at: selectedIndex, from: interactor.allItems)
        bottomBarPresenter?.setupTabBarWith(config: interactor.bottomBarConfig)
    }
    
    func onInfo(object: Item){
        router.onInfo(object: object)
    }
    
    func viewWillDisappear() {
        bottomBarPresenter?.dismiss(animated: false)
    }
    
    func viewFullyLoaded() {
//        bottomBarPresenter?.show(animated: false, onView: self.view)
    }
    
    func startCreatingAVAsset(){
        startAsyncOperation()
    }
    
    func stopCreatingAVAsset() {
        asyncOperationSucces()
    }

    func moreButtonPressed(sender: Any?, inAlbumState: Bool) {
        let currentItem = interactor.allItems[interactor.currentItemIndex]
        var actions = [ElementTypes]()
        
        switch currentItem.fileType {
        case .audio, .video, .image:
            actions = interactor.setupedMoreMenuConfig//ActionSheetPredetermendConfigs.photoVideoDetailActions
        case .allDocs:
            actions = ActionSheetPredetermendConfigs.documetsDetailActions
        default:
            break
        }
        alertSheetModule?.showAlertSheet(with: actions,
                                         items: [currentItem],
                                         presentedBy: sender,
                                         onSourceView: nil,
                                         excludeTypes: alertSheetExcludeTypes)
    }
    
    //MARK: presenter output
    
    var selectedItems: [BaseDataSourceItem] {
        let currentItem = interactor.allItems[interactor.currentItemIndex]
        return [currentItem]
    }
    

    func operationFinished(withType type: ElementTypes, response: Any?) {
        switch type {
        case .delete, .removeFromAlbum:
            interactor.deleteSelectedItem()
        case .removeFromFavorites, .addToFavorites:
            interactor.onViewIsReady()
        default:
            break
        }
        
    }
    
    func operationFailed(withType type: ElementTypes) {
        debugPrint("failed")
    }
    
    func goBack() {
        router.goBack(navigationConroller: view.getNavigationController())
    }
    
    func updateItems(objects: [Item], selectedIndex: Int, isRightSwipe: Bool) {
        view.updateItems(objectsArray: objects, selectedIndex: selectedIndex, isRightSwipe: isRightSwipe)
    }
    
    func selectModeSelected() {
        
    }
    
    func selectAllModeSelected() {
        
    }
    
    func printSelected() { }
    func stopModeSelected() { }
    
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}
