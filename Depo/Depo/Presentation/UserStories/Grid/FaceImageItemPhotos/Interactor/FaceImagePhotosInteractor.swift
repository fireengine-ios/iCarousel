//
//  FaceImagePhotosInteractor.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImagePhotosInteractor: BaseFilesGreedInteractor {
    
    let service = AlbumDetailService(requestSize: 1)
    
    var album: AlbumItem?
    
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
    
    fileprivate func update(album: AlbumItem) {
        service.albumCoverPhoto(albumUUID: album.uuid, sortBy: .name, sortOrder: .asc, success: { coverPhoto in
            if album.preview?.uuid != coverPhoto.uuid {
                album.preview = coverPhoto
                ItemOperationManager.default.updatedAlbumCoverPhoto(item: album)
            }
        }, fail: {
            // TODO: NEED TO CHANGE SERVICE FOR ERROR HANDLER
        })
    }
}

// MARK: - FaceImagePhotosInteractorInput

extension FaceImagePhotosInteractor: FaceImagePhotosInteractorInput {
    
    func deletePhotosFromPeopleAlbum(items: [BaseDataSourceItem], id: Int64) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item] {
                self?.output.startAsyncOperation()

                PeopleService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                    self?.output.asyncOperationSucces()
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] (error) in
                    self?.output.asyncOperationFail(errorMessage: error.localizedDescription)
                }
            }
        }
        
        if let output = output as? FaceImagePhotosInteractorOutput {
            output.didRemoveFromAlbum(completion: okHandler)
        }
    }
    
    func deletePhotosFromThingsAlbum(items: [BaseDataSourceItem], id: Int64) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item] {
                self?.output.startAsyncOperation()

                ThingsService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                    self?.output.asyncOperationSucces()
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] (error) in
                    self?.output.asyncOperationFail(errorMessage: error.localizedDescription)
                }
            }
        }
        
        if let output = output as? FaceImagePhotosInteractorOutput {
            output.didRemoveFromAlbum(completion: okHandler)
        }
    }
    
    func deletePhotosFromPlacesAlbum(items: [BaseDataSourceItem], id: Int64) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item] {
                self?.output.startAsyncOperation()

                PlacesService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                    self?.output.asyncOperationSucces()
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] (error) in
                    self?.output.asyncOperationFail(errorMessage: error.localizedDescription)
                }
            }
        }
        
        if let output = output as? FaceImagePhotosInteractorOutput {
            output.didRemoveFromAlbum(completion: okHandler)
        }
    }
    
}
