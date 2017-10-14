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
        if items[index].syncStatus == .notSynced {
            barConfig = EditingBarConfig(elementsConfig: interactor.bottomBarConfig.elementsConfig + [.sync], style: .black, tintColor: nil)
        } else if items[index].syncStatus == .synced {
            barConfig = EditingBarConfig(elementsConfig: interactor.bottomBarConfig.elementsConfig + [.download], style: .black, tintColor: nil)
        }
//        if items[index].fileType == .image {
//            
//        }
        bottomBarPresenter?.setupTabBarWith(config: barConfig)
    }
    
    func setSelectedItemIndex(selectedIndex: Int) {
        interactor.setSelectedItemIndex(selectedIndex: selectedIndex)
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
        
        alertSheetModule?.showAlertSheet(with: [currentItem], presentedBy: sender, onSourceView: nil)

//        bottomBarPresenter?.showAlertSheet(withItems: [currentItem], presentedBy: sender, onSourceView: nil)
        //(withTypes: [.createStory, .move, .addToFavorites, .removeFromAlbum, .backUp], presentedBy: sender)
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
        router.goBack()
    }
    
    func updateItems(objects: [Item], selectedIndex: Int){
        view.updateItems(objectsArray: objects, selectedIndex: selectedIndex)
    }
    
    func selectModeSelected() {
        
    }
    
    func selectAllModeSelected() {
        
    }
    
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}
