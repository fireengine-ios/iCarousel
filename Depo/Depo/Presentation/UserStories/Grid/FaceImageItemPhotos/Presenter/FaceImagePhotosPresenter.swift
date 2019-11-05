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
    
    init(item: Item, isSearchItem: Bool) {
        self.item = item
        self.isSearchItem = isSearchItem
        super.init()
    }
    
    override func viewIsReady(collectionView: UICollectionView) {
        super.viewIsReady(collectionView: collectionView)
        
        if let interactor = interactor as? FaceImagePhotosInteractor {
            dataSource.parentUUID = interactor.album?.uuid
        }
        loadItem()
    }
    
    override func changeCover() {
        if let itemsService = interactor.remoteItems as? FaceImageDetailService,
           let router = router as? FaceImagePhotosRouter {
              router.openChangeCoverWith(itemsService.albumUUID, moduleOutput: self)
        }
    }
    
    override func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) {
        if let interactor = interactor as? FaceImagePhotosInteractor,
            let id = item.id {
            
            if item is PeopleItem {
                interactor.deletePhotosFromPeopleAlbum(items: items, id: id)
            } else if item is ThingsItem {
                interactor.deletePhotosFromThingsAlbum(items: items, id: id)
            } else if item is PlacesItem {
                interactor.deletePhotosFromPlacesAlbum(items: items, id: id)
            }
        }
    }
    
    override func operationFinished(withType type: ElementTypes, response: Any?) {
        if type.isContained(in: [.removeFromAlbum, .removeFromFaceImageAlbum, .delete]) {
            if let interactor = interactor as? FaceImagePhotosInteractorInput {
                interactor.loadItem(item)
            }
        } else if type == .changeCoverPhoto {
            outputView()?.hideSpinner()

            if let view = view as? FaceImagePhotosViewController,
                let item = response as? Item {
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
        
        view.setupHeader(forPeopleItem: item as? PeopleItem)
        
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
            if let view = view as? FaceImagePhotosViewInput {
                view.dismiss()
            }
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
    
    func didRemoveFromAlbum(completion: @escaping (() -> Void)) {
        if let router = router as? FaceImagePhotosRouterInput {
            router.showRemoveFromAlbum(completion: completion)
        }
    }
    
    func didReload() {
        reloadData()
    }
    
}
