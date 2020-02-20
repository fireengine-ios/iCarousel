//
//  FaceImagePhotosInteractor.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImagePhotosInteractor: BaseFilesGreedInteractor {
    
    private let service = AlbumDetailService(requestSize: 1)
    private let peopleService = PeopleService()
    private let thingsService = ThingsService()
    private let placesService = PlacesService()
    
    private lazy var hideActionService: HideActionServiceProtocol = HideActionService()

    var album: AlbumItem?
    var status: ItemStatus = .active
    
    override func viewIsReady() {
        if let output = output as? FaceImagePhotosInteractorOutput,
            let album = album {
            output.didCountImage(album.imageCount ?? 0)
        }
    }
    
    func updateCoverPhotoIfNeeded() {
        if let album = album {
            update(album: album)
        }
    }
    
    private func update(album: AlbumItem) {
        service.albumCoverPhoto(albumUUID: album.uuid, sortBy: .name, sortOrder: .asc, success: { [weak self] coverPhoto in
            if album.preview?.uuid != coverPhoto.uuid {
                album.preview = coverPhoto
                ItemOperationManager.default.updatedAlbumCoverPhoto(item: album)
                if let output = self?.output as? BaseFilesGreedModuleInput {
                    output.operationFinished(withType: .changeCoverPhoto, response: coverPhoto)
                }
            } else {
                if let output = self?.output as? BaseFilesGreedModuleInput {
                    output.operationFinished(withType: .changeCoverPhoto, response: nil)
                }
            }
        }, fail: { [weak self] in
            if let output = self?.output as? BaseFilesGreedModuleInput {
                output.operationFailed(withType: .changeCoverPhoto)
            }
            // TODO: NEED TO CHANGE SERVICE FOR ERROR HANDLER
        })
    }
    
}

// MARK: - FaceImagePhotosInteractorInput

extension FaceImagePhotosInteractor: FaceImagePhotosInteractorInput {
    
    func loadItem(_ item: BaseDataSourceItem) {
        guard let item = item as? Item, item.fileType.isFaceImageType, let id = item.id else {
            return
        }
        
        let successHandler: AlbumOperationResponse = { [weak self] album in
            DispatchQueue.main.async {
                if let output = self?.output as? FaceImagePhotosInteractorOutput,
                    let count = album.imageCount{
                    output.didCountImage(count)
                }
                
                self?.output.asyncOperationSuccess()
            }
        }
        
        let failHandler: FailResponse = { [weak self] error in
            self?.output.asyncOperationFail(errorMessage: error.description)
        }
        
        output.startAsyncOperation()
        
        if item is PeopleItem {
            peopleService.getPeopleAlbum(id: Int(truncatingIfNeeded: id), status: status, success: successHandler, fail: failHandler)
        } else if item is ThingsItem {
            thingsService.getThingsAlbum(id: Int(truncatingIfNeeded: id), status: status, success: successHandler, fail: failHandler)
        } else if item is PlacesItem {
            placesService.getPlacesAlbum(id: Int(truncatingIfNeeded: id), status: status, success: successHandler, fail: failHandler)
        }
    }
    
    func updateCurrentItem(_ item: BaseDataSourceItem) {
        guard let item = item as? Item, let id = item.id else { return }
        
        if item is PeopleItem {
            output.startAsyncOperation()
        
            peopleService.getPeopleAlbum(id: Int(id), status: status, success: { [weak self] album in
                let albumItem = AlbumItem(remote: album)
                self?.remoteItems = FaceImageDetailService(albumUUID: albumItem.uuid, requestSize: RequestSizeConstant.faceImageItemsRequestSize)
                if let output = self?.output as? FaceImagePhotosInteractorOutput {
                    output.didReload()
                }
                
                self?.output.asyncOperationSuccess()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        }
    }
    
    func hideAlbum() {
        guard let album = album else {
            return
        }
        
        hideActionService.startOperation(for: .albums([album]), output: output, success: {  [weak self] in
            self?.output.completeAsyncOperationEnableScreen()
        }, fail: { [weak self] errorResponse in
            self?.output.completeAsyncOperationEnableScreen(errorMessage: errorResponse.description)
        })
    }
}

