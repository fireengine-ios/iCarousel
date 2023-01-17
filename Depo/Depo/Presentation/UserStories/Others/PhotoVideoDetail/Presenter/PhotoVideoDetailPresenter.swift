//
//  PhotoVideoDetailPhotoVideoDetailPresenter.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

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

    var ocrEnabled: Bool {
        FirebaseRemoteConfig.shared.ocrEnabled
    }
    
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
            if let editIndex = actionTypes.firstIndex(of: .edit) {
                actionTypes.remove(at: editIndex)
            }
            if let printIndex = actionTypes.firstIndex(of: .print) {
                actionTypes.remove(at: printIndex)
            }
            if fileTypes.contains(where: { $0.isDocumentPageItem || $0 == .audio }) {
                if let downloadIndex = actionTypes.firstIndex(of: .download) {
                    actionTypes.remove(at: downloadIndex)
                    actionTypes.insert(.downloadDocument, at: downloadIndex)
                }
            }
            barConfig = EditingBarConfig(elementsConfig: actionTypes,
                                         style: barConfig.style,
                                         tintColor: barConfig.tintColor,
                                         unselectedItemTintColor: barConfig.unselectedItemTintColor)
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
        
        guard index < interactor.allItems.count else {
            debugLog("CRASH CASE ---->>> index out of range")
            return
        }
        
        let selectedItems = [interactor.allItems[index]]
        let allSelectedItemsTypes = selectedItems.map { $0.fileType }
        
        let barConfig = prepareBarConfigForFileTypes(fileTypes: allSelectedItemsTypes, selectedIndex: index)
        bottomBarPresenter?.setupTabBarWith(config: barConfig)
    }
    
    func onInfo(object: Item) {
        if !UIDevice.current.orientation.isLandscape {
            view.showBottomDetailView()
        } else {
            router.onInfo(object: object)
        }
    }
    
    func viewWillDisappear() {
        bottomBarPresenter?.dismiss(animated: false)
        interactor.resignUserActivity()
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
        
        guard index < interactor.allItems.count else {
            debugLog("CRASH CASE ---->>> index out of range")
            return
        }
        
        let currentItem = interactor.allItems[index]
        selectedItemsCallback([currentItem])

        // The code here is called when bottom bar buttons or 3 dot barButtonItem tapped.
        // On any of these actions the text selection interaction should be removed from UI
        DispatchQueue.main.async {
            self.view.removeTextSelectionInteractionFromCurrentCell()
        }
    }
    

    func operationFinished(withType type: ElementTypes, response: Any?) {
        switch type {
        case .delete, .removeFromAlbum, .removeFromFaceImageAlbum:
            outputView()?.hideSpinner()
            interactor.deleteSelectedItem(type: type)
        case .removeFromFavorites, .addToFavorites:
            interactor.onViewIsReady()
        case .hide, .unhide, .moveToTrash, .restore, .moveToTrashShared:
            interactor.deleteSelectedItem(type: type)
        case .makeAlbumCover:
            changeCover()
        case .makePersonThumbnail:
            changePeopleThumbnail()
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
    
    func selectModeSelected() {
        
    }
    
    func selectAllModeSelected() {
        
    }
    
    func changeCover() { 
        SnackbarManager.shared.show(type: .nonCritical, message: localized(.changeAlbumCoverSuccess))
    }
    
    func changePeopleThumbnail() {
        SnackbarManager.shared.show(type: .nonCritical, message: localized(.changePersonThumbnailSuccess))
    }
    
    func getFIRParent() -> Item? {
        return item
    }
    
    func openInstaPick() { }
    
    func deSelectAll() {
        
    }
    
    func printSelected() {
        view.printSelected()
    }

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

    func cancelSaveDescription(use description: String) {
        asyncOperationSuccess()
        view.showDescription(description: description)
    }
    
    func failedUpdate(error: Error) {
        asyncOperationSuccess()
        view.showErrorAlert(message: error.description)
    }
    
    func didValidateNameSuccess(name: String) {
        view.showValidateNameSuccess(name: name)
        interactor.onRename(newName: name)
    }

    func didValidateDescriptionSuccess(description: String) {
        view.showValidateDescriptionSuccess(description: description)
        interactor.onEditDescription(newDescription: description)
    }

    func updatePeople(items: [PeopleOnPhotoItemResponse]) {
        asyncOperationSuccess()
        view.updatePeople(items: items)
    }
    
    func getFIRStatus(completion: VoidHandler? = nil) {
        interactor.getFIRStatus(success: { [weak self] settings in
            self?.isFaceImageAllowed = settings.isFaceImageAllowed == true
            self?.view.setHiddenPeoplePlaceholder(isHidden: self?.isFaceImageAllowed == true)
            if settings.isFaceImageAllowed == true {
                    self?.interactor.getAuthority()
                    completion?()
            } else {
                self?.view.setHiddenPremiumStackView(isHidden: true)
                completion?()
            }
        }, fail: { [weak self] error in
            self?.failedUpdate(error: error)
        })
    }
    
    func didLoadAlbum(_ album: AlbumServiceResponse, forItem item: Item) {
        asyncOperationSuccess()
        let albumItem = AlbumItem(remote: album)
        router.openFaceImageItemPhotosWith(item, album: albumItem, moduleOutput: view.bottomDetailViewManager?.managedView)
    }
    
    func didFailedLoadAlbum(error: Error) {
        asyncOperationSuccess()
        view.showErrorAlert(message: error.description)
    }
    
    func didLoadFaceRecognitionPermissionStatus(_ isPermitted: Bool) {
        view.setHiddenPremiumStackView(isHidden: isPermitted)
    }

    @available(iOS 13.0, *)
    func setCurrentActivityItemsConfiguration(_ config: UIActivityItemsConfiguration?) {
        view.activityItemsConfiguration = config
    }
    
    func configureFileInfo(_ view: FileInfoView) {
        view.output = self
    }
    func getPersonsForSelectedPhoto(completion: VoidHandler? = nil) {
        guard isFaceImageAllowed, let index = interactor.currentItemIndex, let uuid = interactor.allItems[safe: index]?.uuid else {
            return
        }
        interactor.getPersonsOnPhoto(uuid: uuid, completion: completion)
    }
}

extension PhotoVideoDetailPresenter: PhotoInfoViewControllerOutput {
    func onRename(newName: String) {
        startAsyncOperation()
        interactor.onValidateName(newName: newName)
    }

    func onEditDescription(newDescription: String) {
        startAsyncOperation()
        interactor.onEditDescription(newDescription: newDescription)
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
                self?.getPersonsForSelectedPhoto() {
                    self?.interactor.getAuthority()
                }
            }
        }
    }
    
    func onBecomePremiumDidTap() {
        router.goToPremium()
    }
    
    func onPeopleAlbumDidTap(_ album: PeopleOnPhotoItemResponse) {
        guard let id = album.personInfoId else {
            return
        }
        
        startAsyncOperation()
        
        let peopleItemResponse = PeopleItemResponse()
        peopleItemResponse.id = id
        peopleItemResponse.name = album.name ?? ""
        peopleItemResponse.thumbnail = album.thumbnailURL
        let peopleItem = PeopleItem(response: peopleItemResponse)
        interactor.getPeopleAlbum(with: peopleItem, id: id)
    }
    
    func tapGesture(recognizer: UITapGestureRecognizer) {
        view.closeDetailViewIfNeeded()
    }
    
    func onSelectSharedContact(_ contact: SharedContact) {
        guard let index = interactor.currentItemIndex else {
            return
        }
        let currentItem = interactor.allItems[index]
        router.openPrivateShareAccessList(projectId: currentItem.projectId ?? "",
                                          uuid: currentItem.uuid,
                                          contact: contact,
                                          fileType: currentItem.fileType)
    }
        
    func onAddNewShare() {
        guard let index = interactor.currentItemIndex else {
            return
        }
        let currentItem = interactor.allItems[index]
        router.openPrivateShare(for: currentItem)
    }
    
    func showWhoHasAccess(shareInfo: SharedFileInfo) {
        router.openPrivateShareContacts(with: shareInfo)
    }
    
    func didUpdateSharingInfo(_ sharingInfo: SharedFileInfo) {
        let item = WrapData(privateShareFileInfo: sharingInfo)
        view.updateExpiredItem(item)
        interactor.updateExpiredItem(item)
    }
    
    func updateItem(_ item: WrapData) {
        view.updateItem(item)
    }
    
    func createNewUrl() {
        interactor.createNewUrl()
    }

    func recognizeTextForCurrentItem(image: UIImage, completion: @escaping (ImageTextSelectionData?) -> Void) {
        interactor.recognizeTextForCurrentItem(image: image, completion: completion)
    }
}

//MARK: - PhotoVideoDetailRouterOutput

extension PhotoVideoDetailPresenter: PhotoVideoDetailRouterOutput {
    
    func updateShareInfo() {
        view.updateBottomDetailView()
    }
    
    func deleteShareInfo() {
        view.deleteShareInfo()
    }
}
