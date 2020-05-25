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
        
        switch view.status {
        case .hidden:
            actions = ActionSheetPredetermendConfigs.hiddenDetailActions
        case .trashed:
            actions = ActionSheetPredetermendConfigs.trashedDetailActions
        default:
            switch object.fileType {
            case .audio:
                actions = ActionSheetPredetermendConfigs.audioDetailActions
            case .image, .video:
                actions = interactor.setupedMoreMenuConfig
            case .allDocs:
                actions = ActionSheetPredetermendConfigs.documetsDetailActions
            default:
                break
            }
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
    
    func willDisplayLastCell() {
        if canLoadMoreItems {
            moduleOutput?.needLoadNextPage()
        }
    }
    
    // MARK: presenter output
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        guard let index = interactor.currentItemIndex else {
            return
        }
        let currentItem = interactor.allItems[index]
        selectedItemsCallback([currentItem])
    }
    

    func operationFinished(withType type: ElementTypes, response: Any?) {
        switch type {
        case .delete, .removeFromAlbum, .removeFromFaceImageAlbum:
            outputView()?.hideSpinner()
            interactor.deleteSelectedItem(type: type)
        case .removeFromFavorites, .addToFavorites:
            interactor.onViewIsReady()
        case .hide, .unhide, .moveToTrash, .restore:
            interactor.deleteSelectedItem(type: type)
        default:
            break
        }
        
    }
    
    func operationFailed(withType type: ElementTypes) {
        outputView()?.hideSpinner()

        debugPrint("failed")
    }
    
    func successPopupClosed() {
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
    
    func selectModeSelected() {
        
    }
    
    func selectAllModeSelected() {
        
    }
    
    func changeCover() { 
    
    }
    
    func getFIRParent() -> Item? {
        return item
    }
    
    func openInstaPick() { }
    
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
    
    func updatePeople(items: [PeopleOnPhotoItemResponse]) {
        asyncOperationSuccess()
        view.updatePeople(items: items)
    }
    
    func getFIRStatus() {
        interactor.getFIRStatus(success: { [weak self] settings in
            self?.isFaceImageAllowed = settings.isFaceImageAllowed == true
            self?.view.setHiddenPeoplePlaceholder(isHidden: self?.isFaceImageAllowed == true)
            self?.interactor.getAuthority()
            self?.getPersonsForSelectedPhoto()
        }, fail: { [weak self] error in
            self?.failedUpdate(error: error)
        })
    }
    
    func didLoadAlbum(_ album: AlbumServiceResponse, forItem item: Item) {
        let albumItem = AlbumItem(remote: album)
        router.openFaceImageItemPhotosWith(item, album: albumItem)
    }
    
    func didLoadFaceRecognitionPermissionStatus(_ isPermitted: Bool) {
        view.setHiddenPremiumStackView(isHidden: isPermitted)
    }
    
    func configureFileInfo(_ view: FileInfoView) {
        view.output = self
    }
    
    func getPersonsForSelectedPhoto() {
        guard isFaceImageAllowed, let index = interactor.currentItemIndex, let uuid = interactor.allItems[safe: index]?.uuid else {
            return
        }
        interactor.getPersonsOnPhoto(uuid: uuid)
    }
}

extension PhotoVideoDetailPresenter: PhotoInfoViewControllerOutput {
    func onRename(newName: String) {
        startAsyncOperation()
        interactor.onValidateName(newName: newName)
    }
    
    func onEnableFaceRecognitionDidTap() {
        router.showConfirmationPopup { [weak self] in
            self?.interactor.enableFIR() { [weak self] in
                SnackbarManager.shared.show(
                    type: .nonCritical,
                    message: TextConstants.faceImageEnableSnackText,
                    action: .none
                )
                self?.isFaceImageAllowed = true
                self?.view.setHiddenPeoplePlaceholder(isHidden: true)
                self?.interactor.getAuthority()
                self?.getPersonsForSelectedPhoto()
            }
        }
    }
    
    func onBecomePremiumDidTap() {
        router.goToPremium()
    }
    
    func onPeopleAlbumDidTap(_ album: PeopleOnPhotoItemResponse) {
        guard
            let index = interactor.currentItemIndex,
            let mediaItem = interactor.allItems[safe: index],
            let id = album.personInfoId
        else {
            return
        }
        view.closeDetailViewIfNeeded()
        interactor.getPeopleAlbum(with: mediaItem, id: id)
    }
}
