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
        if type.isContained(in: [.removeFromAlbum, .removeFromFaceImageAlbum, .moveToTrash]) {
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
        //hide or delete fir album
        if
            let album = items.first as? AlbumItem,
            let interactor = interactor as? FaceImagePhotosInteractor,
            album == interactor.album
        {
            faceImageItemsModuleOutput?.delete(item: item)
            goBack()
            return
        }
        
        if dataSource.allObjectIsEmpty() {
            faceImageItemsModuleOutput?.delete(item: item)
            backToOriginController()
        } else {
            if let interactor = interactor as? FaceImagePhotosInteractorInput {
                interactor.loadItem(item)
            }
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
    
    func didMoveToTrashItems(_ items: [Item]) {
        backToOriginController()
    }
    
    func didMoveToTrashPeople(items: [PeopleItem]) {
        backToOriginController()
    }
    
    func didMoveToTrashThings(items: [ThingsItem]) {
        backToOriginController()
    }
    
    func didMoveToTrashPlaces(items: [PlacesItem]) {
        backToOriginController()
    }
    
    func didUnhideItems(_ items: [WrapData]) {
        backToOriginController()
    }
    
    func didUnhidePeople(items: [PeopleItem]) {
        backToOriginController()
    }
    
    func didUnhideThings(items: [ThingsItem]) {
        backToOriginController()
    }
    
    func didUnhidePlaces(items: [PlacesItem]) {
        backToOriginController()
    }
    
    func putBackFromTrashItems(_ items: [Item]) {
        backToOriginController()
    }
    
    func putBackFromTrashPeople(items: [PeopleItem]) {
        backToOriginController()
    }
    
    func putBackFromTrashPlaces(items: [PlacesItem]) {
        backToOriginController()
    }
    
    func putBackFromTrashThings(items: [ThingsItem]) {
        backToOriginController()
    }
    
    func deleteItems(items: [Item]) {
        backToOriginController()
    }
    
    func goBack() {
        guard !isDismissing else {
            return
        }
        
        isDismissing = true
        router.back()
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
