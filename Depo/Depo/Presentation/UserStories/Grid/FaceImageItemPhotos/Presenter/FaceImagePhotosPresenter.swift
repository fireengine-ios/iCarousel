//
//  FaceImagePhotosPresenter.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImagePhotosPresenter: BaseFilesGreedPresenter {
    
    weak var faceImageItemsModuleOutput: FaceImageItemsModuleOutput?
    
    var coverPhoto: Item?
    var item: Item
    
    var isSearchItem: Bool
    
    private var isDismissing = false
    
    init(item: Item, isSearchItem: Bool) {
        self.item = item
        self.isSearchItem = isSearchItem
        super.init()
        dataSource = FaceImagePhotosDataSource(sortingRules: sortedRule)
        (dataSource as? FaceImagePhotosDataSource)?.item = item
        
        ItemOperationManager.default.startUpdateView(view: self)
    }
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        
        if let interactor = interactor as? FaceImagePhotosInteractor {
            dataSource.parentUUID = interactor.album?.uuid
            (dataSource as? FaceImagePhotosDataSource)?.album = interactor.album
        }
        loadItem()
    }
    
    override func changeCover() {
        if let itemsService = interactor.remoteItems as? FaceImageDetailService,
           let router = router as? FaceImagePhotosRouter {
              router.openChangeCoverWith(itemsService.albumUUID, moduleOutput: self)
        }
    }
    
    override func getFIRParent() -> Item? {
        return item
    }
    
    override func operationFinished(withType type: ElementTypes, response: Any?) {
        if type.isContained(in: [.removeFromAlbum, .removeFromFaceImageAlbum]) {
            if let interactor = interactor as? FaceImagePhotosInteractorInput {
                interactor.loadItem(item)
            }
        } else if type == .changeCoverPhoto {
            outputView()?.hideSpinner()

            if let view = view as? FaceImagePhotosViewController, let item = response as? Item {
                view.setHeaderImage(with: item.patchToPreview)
            }
        }
    }
    
    override func operationFailed(withType type: ElementTypes) {
        outputView()?.hideSpinner()
    }
    
    override func getContentWithSuccess(items: [WrapData]) {
        super.getContentWithSuccess(items: items)
        
        if let interactor = interactor as? FaceImagePhotosInteractorInput {
            interactor.loadItem(item)
        }
    }
    
    override func filesAppendedAndSorted() {
        super.filesAppendedAndSorted()
        
        if !dataSource.isPaginationDidEnd && dataSource.allItems.isEmpty {
            getNextItems()
        }
    }
    
    override func getSortTypeString() -> String {
        return ""
    }
    
    private func loadItem() {
        guard let view = view as? FaceImagePhotosViewController else {
            return
        }
        
        let status = (interactor as? FaceImagePhotosInteractor)?.status
        view.setupHeader(with: item, status: status)
            
        if let path = coverPhoto?.patchToPreview {
            view.setHeaderImage(with: path)
        }
 
    }
    
    override func updateThreeDotsButton() {
        view.setThreeDotsMenu(active: true)
    }
    
    // MARK: - BaseDataSourceForCollectionViewDelegate
    
    override func updateCoverPhotoIfNeeded() {
        if let interactor = interactor as? FaceImagePhotosInteractor {
            interactor.updateCoverPhotoIfNeeded()
        }
    }
    
    override func didDelete(items: [BaseDataSourceItem]) {
        if dataSource.allObjectIsEmpty() {
            faceImageItemsModuleOutput?.delete(item: item)
            setupBackHandler(toOriginal: true)
        } else if let interactor = interactor as? FaceImagePhotosInteractorInput {
            interactor.loadItem(item)
        }
    }
}

// MARK: FaceImageChangeCoverModuleOutput

extension FaceImagePhotosPresenter: FaceImageChangeCoverModuleOutput {
    
    func onAlbumCoverSelected(item: WrapData) {
        if let view = view as? FaceImagePhotosViewController {
            view.setHeaderImage(with: item.patchToPreview)
        }
    }
    
}

// MARK: FaceImagePhotosViewOutput

extension FaceImagePhotosPresenter: FaceImagePhotosViewOutput {
    
    func openAddName() {
        if let router = router as? FaceImagePhotosRouter {
            router.openAddName(item, moduleOutput: self, isSearchItem: isSearchItem)
        }
    }
    
    func hideAlbum() {
        if let interactor = interactor as? FaceImagePhotosInteractor {
            interactor.hideAlbum()
        }
    }
    
    func faceImageType() -> FaceImageType? {
        if item is PeopleItem {
            return .people
        }
        if item is ThingsItem {
            return .things
        }
        if item is PlacesItem {
            return .places
        }
        return nil
    }
    
}

// MARK: FaceImagePhotosModuleOutput

extension FaceImagePhotosPresenter: FaceImagePhotosModuleOutput {
    
    func didChangeName(item: WrapData) {
        if let view = view as? FaceImagePhotosViewInput,
            let name = item.name {
            view.reloadName(name)
            faceImageItemsModuleOutput?.didChangeName(item: item)
        }
    }
    
    func didMergePeople() {
        faceImageItemsModuleOutput?.didReloadData()
    }
    
    func didMergeAfterSearch(item: Item) {
        self.item = item
        if let interactor = interactor as? FaceImagePhotosInteractorInput {
            interactor.updateCurrentItem(item)
        }
        
        if let view = view as? FaceImagePhotosViewInput,
            let name = item.name {
            view.reloadName(name)
            view.setHeaderImage(with: item.patchToPreview)
        }
    }
    
    func getSliderItmes(items: [SliderItem]) {
        if let view = view as? FaceImagePhotosViewInput {
            view.hiddenSlider(isHidden: items.count == 0)
        }
    }
    
}

// MARK: FaceImagePhotosInteractorOutput

extension FaceImagePhotosPresenter: FaceImagePhotosInteractorOutput {
    
    func didCountImage(_ count: Int) {
        if let view = view as? FaceImagePhotosViewInput {
            view.setCountImage("\(count) \(TextConstants.faceImagePhotos)")
        }
    }
    
    func didReload() {
        reloadData()
    }
    
}

extension FaceImagePhotosPresenter: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        guard let obj = object as? FaceImagePhotosPresenter else {
            return false
        }
        
        return obj.item == self.item
    }
    
    //MARK: MoveToTrash
    
    func didMoveToTrashItems(_ items: [Item]) {
        guard items.first?.status == .hidden else {
            return
        }
        setupBackHandler(toOriginal: true)
    }
    
    func didMoveToTrashPeople(items: [PeopleItem]) {
        guard items.first?.status == .hidden else {
            return
        }
        setupBackHandler(toOriginal: true)
    }
    
    func didMoveToTrashThings(items: [ThingsItem]) {
        guard items.first?.status == .hidden else {
            return
        }
        setupBackHandler(toOriginal: true)
    }
    
    func didMoveToTrashPlaces(items: [PlacesItem]) {
        guard items.first?.status == .hidden else {
            return
        }
        setupBackHandler(toOriginal: true)
    }
    
    //MARK: Unhide
    
    func didUnhideItems(_ items: [WrapData]) {
        setupBackHandler(toOriginal: true)
    }
    
    func didUnhidePeople(items: [PeopleItem]) {
        setupBackHandler(toOriginal: true)
    }
    
    func didUnhideThings(items: [ThingsItem]) {
        setupBackHandler(toOriginal: true)
    }
    
    func didUnhidePlaces(items: [PlacesItem]) {
        setupBackHandler(toOriginal: true)
    }
    
    //MARK: Restore
    
    func putBackFromTrashItems(_ items: [Item]) {
        setupBackHandler(toOriginal: true)
    }
    
    func putBackFromTrashPeople(items: [PeopleItem]) {
        setupBackHandler(toOriginal: true)
    }
    
    func putBackFromTrashPlaces(items: [PlacesItem]) {
        setupBackHandler(toOriginal: true)
    }
    
    func putBackFromTrashThings(items: [ThingsItem]) {
        setupBackHandler(toOriginal: true)
    }
    
    //MARK: Delete
    
    func deleteItems(items: [Item]) {
        setupBackHandler(toOriginal: true)
    }
    
    func goBack() {
        guard !isDismissing else {
            return
        }
        
        isDismissing = true
        router.back()
    }
    
    private func setupBackHandler(toOriginal: Bool) {
        backHandler = { [weak self] in
            if toOriginal {
                self?.backToOriginController()
            } else {
                self?.router.back()
            }
        }
    }
    
    private func backToOriginController() {
        guard let controller = getBackController(), !isDismissing else {
            return
        }
        
        isDismissing = true
        router.back(to: controller)
    }
    
    private func getBackController() -> UIViewController? {
        let navVC = (view as? UIViewController)?.navigationController
        let destinationIndex = navVC?.viewControllers.lastIndex(where: {
            ($0 is HiddenPhotosViewController) || ($0 is SegmentedController)
        })
        guard let index = destinationIndex, let destination = navVC?.viewControllers[safe: index] else {
            return nil
        }
        
        return destination
    }
}

extension FaceImagePhotosPresenter: FaceImagePhotosDataSourceDelegate {
    func didFinishFIRAlbum(operation: ElementTypes, album: Item) {
        faceImageItemsModuleOutput?.delete(item: item)
        
        switch operation {
        case .unhide, .moveToTrash, .delete, .restore:
            setupBackHandler(toOriginal: false)
        case .hide:
            router.back()
        default:
            break 
        }
        
    }
}
