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
    
    var alertSheetModule: AlertFilesActionsSheetModuleInput?
    
    func viewIsReady(view: UIView) {
        interactor.onViewIsReady()
         bottomBarPresenter?.show(animated: false, onView: view)
//        if inte
    }
    
    func onShowSelectedItem(at index: Int, from items:[Item]) {
        view.onShowSelectedItem(at: index, from: items)
        var barConfig = interactor.bottomBarConfig
        
        
//        if items[index].fileType == .image {
//            
//        }
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

    func moreButtonPressed(sender: Any?) {
        let currentItem = interactor.allItems[interactor.currentItemIndex]
        alertSheetModule?.showAlertSheet(with: ActionSheetPredetermendConfigs.photoVideoDetailActions,
                                         items: [currentItem],
                                         presentedBy: sender,
                                         onSourceView: nil,
                                         excludeTypes: [.delete])
    }
    
    //MARK: presenter output
    
    var selectedItems: [BaseDataSourceItem] {
        let currentItem = interactor.allItems[interactor.currentItemIndex]
        return [currentItem]
    }
    

    func operationFinished(withType type: ElementTypes, response: Any?) {
        if (type == .delete){
            interactor.deleteSelectedItem()
        }
        debugPrint("finished")
    }
    
    func operationFailed(withType type: ElementTypes) {
        debugPrint("failed")
    }
    
    func goBack(){
        router.goBack(navigationConroller: view.getNavigationController())
    }
    
    func updateItems(objects: [Item], selectedIndex: Int){
        view.updateItems(objectsArray: objects, selectedIndex: selectedIndex)
    }
    
    func selectModeSelected() {
        
    }
    
    func selectAllModeSelected() {
        
    }
    
    func printSelected() { }
    func shareModeSelected() { }
    
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}
