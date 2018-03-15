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
    
    func deletePhotosFromPeopleAlbum(items: [BaseDataSourceItem], id: Int64, title: String, message: String) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item],
                let uuid = self?.album?.uuid {
                self?.output.startAsyncOperation()

                PeopleService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                    ItemOperationManager.default.filesRomovedFromAlbum(items: items, albumUUID: uuid)
                    
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] error in
                    self?.output.asyncOperationFail(errorMessage: error.localizedDescription)
                }
            }
        }
        
        if let output = output as? FaceImagePhotosInteractorOutput {
            output.didRemoveFromAlbum(completion: okHandler, title: title, message: message)
        }
    }
    
    func deletePhotosFromThingsAlbum(items: [BaseDataSourceItem], id: Int64, title: String, message: String) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item],
                let uuid = self?.album?.uuid {
                self?.output.startAsyncOperation()

                ThingsService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                    ItemOperationManager.default.filesRomovedFromAlbum(items: items, albumUUID: uuid)
                    
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] error in
                    self?.output.asyncOperationFail(errorMessage: error.localizedDescription)
                }
            }
        }
        
        if let output = output as? FaceImagePhotosInteractorOutput {
            output.didRemoveFromAlbum(completion: okHandler, title: title, message: message)
        }
    }
    
    func deletePhotosFromPlacesAlbum(items: [BaseDataSourceItem], id: Int64, title: String, message: String) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item],
                let uuid = self?.album?.uuid {
                self?.output.startAsyncOperation()

                PlacesService().deletePhotosFromAlbum(uuid: uuid, photos: items, success: { [weak self] in
                    ItemOperationManager.default.filesRomovedFromAlbum(items: items, albumUUID: uuid)
                    
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] error in
                    self?.output.asyncOperationFail(errorMessage: error.localizedDescription)
                }
            }
        }
        
        if let output = output as? FaceImagePhotosInteractorOutput {
            output.didRemoveFromAlbum(completion: okHandler, title: title, message: message)
        }
    }
    
}
