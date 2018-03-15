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
    
    init(item: Item) {
        self.item = item
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
        if type == .removeFromAlbum || type == .removeFromFaceImageAlbum || type == .delete {
            dataSource.reloadData()
            faceImageItemsModuleOutput?.didReloadData()
        } else if type == .changeCoverPhoto {
            outputView()?.hideSpiner()

            if let view = view as? FaceImagePhotosViewController,
                let item = response as? Item {
                view.setHeaderImage(with: item.patchToPreview)
            }
        }
    }
    
    override func operationFailed(withType type: ElementTypes) {
        outputView()?.hideSpiner()
    }
    
    override func getContentWithSuccess(items: [WrapData]) {
        super.getContentWithSuccess(items: items)
        
        if let view = view as? FaceImagePhotosViewInput {
            view.setCountImage("\(items.count) \(TextConstants.faceImagePhotos)")
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
            if let view = view as? FaceImagePhotosViewInput {
                var count = 0
                for items in dataSource.getAllObjects() {
                    count += items.count
                }
                
                view.setCountImage("\(count) \(TextConstants.faceImagePhotos)")
                
                if let interactor = interactor as? FaceImagePhotosInteractor {
                    interactor.updateCoverPhotoIfNeeded()
                }
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
            router.openAddName(item, moduleOutput: self)
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
    
    func getSliderItmes(items: [SliderItem]) {
        if let view = view as? FaceImagePhotosViewInput {
            view.hiddenSlider(isHidden: items.count == 0)
        }
    }
    
}

// MARK: FaceImagePhotosModuleOutput

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
    
}
