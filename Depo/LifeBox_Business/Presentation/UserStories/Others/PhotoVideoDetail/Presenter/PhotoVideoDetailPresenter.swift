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
    weak var moduleOutput: PhotoVideoDetailModuleOutput?

    weak var bottomBarPresenter: BottomSelectionTabBarModuleInput?
    var alertSheetModule: AlertFilesActionsSheetModuleInput?
    
    var alertSheetExcludeTypes = [ElementTypes]()
    
    var item: Item?
    private var allSelectedItemsTypes: [FileType]?
    
    var canLoadMoreItems = true
    
    private var isFaceImageAllowed = false
    
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
            if fileTypes.contains(where: { $0.isDocumentPageItem || $0 == .audio }) {
                if let downloadIndex = actionTypes.index(of: .download) {
                    actionTypes.remove(at: downloadIndex)
                    actionTypes.insert(.downloadDocument, at: downloadIndex)
                }
            }
            
            let style: BottomActionsBarStyle
            if fileTypes.contains(where: { $0.isDocumentPageItem }) {
                style = .opaque
            } else {
                style = .transparent
            }
            
            barConfig = EditingBarConfig(elementsConfig: actionTypes, style: style)
        }
        return barConfig
    }
    
    func onShowSelectedItem(at index: Int, from items: [Item]) {
        guard 0..<items.count ~= index else {
            goBack()
            return
        }
        
        view.onShowSelectedItem(at: index, from: items)
        getSelectedItems { [weak self] selectedItems in
            guard let self = self else {
                return
            }
            let allSelectedItemsTypes = selectedItems.map { $0.fileType }
            
            if self.allSelectedItemsTypes != allSelectedItemsTypes {
                let barConfig = self.prepareBarConfigForFileTypes(fileTypes: allSelectedItemsTypes, selectedIndex: index)
                self.bottomBarPresenter?.setupTabBarWith(config: barConfig)
                self.allSelectedItemsTypes = allSelectedItemsTypes
            }
            
            self.view.onItemSelected(at: index, from: items)
        }
    }
    
    func setSelectedItemIndex(selectedIndex: Int) {
        if interactor.allItems.isEmpty {
            return
        }
        
        view.onItemSelected(at: selectedIndex, from: interactor.allItems)
        
        let selectedItem = interactor.allItems[selectedIndex]
        let allSelectedItemsTypes = [selectedItem.fileType]
        
        let barConfig = prepareBarConfigForFileTypes(fileTypes: allSelectedItemsTypes, selectedIndex: selectedIndex)
        bottomBarPresenter?.setupTabBarWith(config: barConfig)
        interactor.currentItemIndex = selectedIndex
    }
    
    func updateBars() {
        guard !interactor.allItems.isEmpty, let index = interactor.currentItemIndex else {
            return
        }
        
        view.onItemSelected(at: index, from: interactor.allItems)
        
        let selectedItems = [interactor.allItems[index]]
        let allSelectedItemsTypes = selectedItems.map { $0.fileType }
        
        let barConfig = prepareBarConfigForFileTypes(fileTypes: allSelectedItemsTypes, selectedIndex: index)
        bottomBarPresenter?.setupTabBarWith(config: barConfig)
    }
    
    func updateBottomBar() {
        guard !interactor.allItems.isEmpty, let index = interactor.currentItemIndex else {
            return
        }
        
        let selectedItems = [interactor.allItems[index]]
        let allSelectedItemsTypes = selectedItems.map { $0.fileType }
        
        let barConfig = prepareBarConfigForFileTypes(fileTypes: allSelectedItemsTypes, selectedIndex: index)
        bottomBarPresenter?.setupTabBarWith(config: barConfig)
    }
    
    func onInfo(object: Item) {
        router.onInfo(object: object)
    }
    
    func viewWillDisappear() {
        bottomBarPresenter?.dismiss(animated: false)
    }
    
    func startCreatingAVAsset() {
        startAsyncOperation()
    }
    
    func stopCreatingAVAsset() {
        asyncOperationSuccess()
    }

    func moreButtonPressed(sender: Any?, inAlbumState: Bool, object: Item, selectedIndex: Int) {
        let actions = ElementTypes.specifiedMoreActionTypes(for: object.status, item: object)
        
        alertSheetModule?.showAlertSheet(with: actions,
                                         items: [object],
                                         presentedBy: sender,
                                         onSourceView: nil,
                                         excludeTypes: alertSheetExcludeTypes)
    }
    
    func replaceUploaded(_ item: WrapData) {
        interactor.replaceUploaded(item)
    }
    
    func willDisplayLastCell() {
        if canLoadMoreItems {
            moduleOutput?.needLoadNextPage()
        }
    }
    
    // MARK: presenter output
    
    func getSelectedItems(selectedItemsCallback: @escaping ValueHandler<[BaseDataSourceItem]>) {
        guard let index = interactor.currentItemIndex else {
            return
        }
        let currentItem = interactor.allItems[index]
        selectedItemsCallback([currentItem])
    }
    

    func operationFinished(withType type: ElementTypes, response: Any?) {
        switch type {
        case .delete:
            outputView()?.hideSpinner()
            interactor.deleteSelectedItem(type: type)
        case .removeFromFavorites, .addToFavorites:
            interactor.onViewIsReady()
        case .moveToTrash, .restore, .moveToTrashShared:
            interactor.deleteSelectedItem(type: type)
        default:
            break
        }
    }
    
    func operationFailed(withType type: ElementTypes) {
        outputView()?.hideSpinner()

        debugPrint("failed")
    }
    
    func successPopupWillAppear() {
        if interactor.allItems.isEmpty {
            goBack()
        }
    }
    
    func goBack() {
        view.hideView()
    }
    
    func updateItems(objects: [Item], selectedIndex: Int) {
        view.updateItems(objectsArray: objects, selectedIndex: selectedIndex)
    }
    
    func onLastRemoved() {
        view.onLastRemoved()
        goBack()
    }
    
    func selectModeSelected(with item: WrapData?) {
        
    }
    
    func selectAllModeSelected() {
        
    }
    
    func deSelectAll() {
        
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
    
    // ModuleInput
    var itemsType: FileType? {
        interactor.allItems.first?.fileType
    }
    
    func appendItems(_ items: [Item], isLastPage: Bool) {
        if isLastPage {
            canLoadMoreItems = false
        }
        
        if items.isEmpty {
            if !isLastPage {
                //autoload next page for filtered items
                moduleOutput?.needLoadNextPage()
            }
        } else {
            DispatchQueue.main.async {
                self.interactor.appendItems(items)
                self.view.appendItems(items)
            }
        }
    }
    
    func tabIndex(type: ElementTypes) -> Int? {
        guard let index = interactor.currentItemIndex else {
            return nil
        }
        
        let item = interactor.allItems[index]
        let types = prepareBarConfigForFileTypes(fileTypes: [item.fileType], selectedIndex: index)
        return types.elementsConfig.firstIndex(of: type)
    }
    
    func updated() {
        asyncOperationSuccess()
    }
    
    func cancelSave(use name: String) {
        asyncOperationSuccess()
        view.show(name: name)
    }
    
    func failedUpdate(error: Error) {
        asyncOperationSuccess()
        view.showErrorAlert(message: error.description)
    }
    
    func didValidateNameSuccess(name: String) {
        view.showValidateNameSuccess(name: name)
        interactor.onRename(newName: name)
    }
    
    func didFailedLoadAlbum(error: Error) {
        asyncOperationSuccess()
        view.showErrorAlert(message: error.description)
    }

    func updateItem(_ item: WrapData) {
        view.updateItem(item)
    }

    func createNewUrl(at index: Int) {
        interactor.createNewUrl(at: index)
    }
}

//MARK: - PhotoVideoDetailRouterOutput

extension PhotoVideoDetailPresenter: PhotoVideoDetailRouterOutput {
    
    func updateShareInfo() { }
}
