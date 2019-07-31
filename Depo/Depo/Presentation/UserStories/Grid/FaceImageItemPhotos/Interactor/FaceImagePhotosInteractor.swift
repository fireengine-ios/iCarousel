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
    
    func deletePhotosFromPeopleAlbum(items: [BaseDataSourceItem], id: Int64) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item],
                let uuid = self?.album?.uuid {
                self?.output.startAsyncOperation()

                PeopleService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                    DispatchQueue.main.async {
                        ItemOperationManager.default.filesRomovedFromAlbum(items: items, albumUUID: uuid)
                        
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] error in
                    self?.output.asyncOperationFail(errorMessage: error.description)
                }
            }
        }
        
        if let output = output as? FaceImagePhotosInteractorOutput {
            output.didRemoveFromAlbum(completion: okHandler)
        }
    }
    
    func deletePhotosFromThingsAlbum(items: [BaseDataSourceItem], id: Int64) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item],
                let uuid = self?.album?.uuid {
                self?.output.startAsyncOperation()

                ThingsService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                    DispatchQueue.main.async {
                        ItemOperationManager.default.filesRomovedFromAlbum(items: items, albumUUID: uuid)
                    
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] error in
                    self?.output.asyncOperationFail(errorMessage: error.description)
                }
            }
        }
        
        if let output = output as? FaceImagePhotosInteractorOutput {
            output.didRemoveFromAlbum(completion: okHandler)
        }
    }
    
    func deletePhotosFromPlacesAlbum(items: [BaseDataSourceItem], id: Int64) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item],
                let uuid = self?.album?.uuid {
                self?.output.startAsyncOperation()

                PlacesService().deletePhotosFromAlbum(uuid: uuid, photos: items, success: { [weak self] in
                    DispatchQueue.main.async {
                        ItemOperationManager.default.filesRomovedFromAlbum(items: items, albumUUID: uuid)
                    
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] error in
                    self?.output.asyncOperationFail(errorMessage: error.description)
                }
            }
        }
        
        if let output = output as? FaceImagePhotosInteractorOutput {
            output.didRemoveFromAlbum(completion: okHandler)
        }
    }
    
    func loadItem(_ item: BaseDataSourceItem) {
        guard let item = item as? Item, let id = item.id else { return }
        
        if item is PeopleItem {
            output.startAsyncOperation()
            
            peopleService.getPeopleAlbum(id: Int(id), success: { [weak self] album in
                if let output = self?.output as? FaceImagePhotosInteractorOutput,
                    let count = album.imageCount{
                    output.didCountImage(count)
                }
                
                self?.output.asyncOperationSuccess()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        } else if item is ThingsItem {
            output.startAsyncOperation()
            
            thingsService.getThingsAlbum(id: Int(id), success: { [weak self] album in
                if let output = self?.output as? FaceImagePhotosInteractorOutput,
                    let count = album.imageCount{
                    output.didCountImage(count)
                }
                
                self?.output.asyncOperationSuccess()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        } else if item is PlacesItem {
            output.startAsyncOperation()
            
            placesService.getPlacesAlbum(id: Int(id), success: { [weak self] album in
                if let output = self?.output as? FaceImagePhotosInteractorOutput,
                    let count = album.imageCount{
                    output.didCountImage(count)
                }
                
                self?.output.asyncOperationSuccess()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        }
    }
    
    func updateCurrentItem(_ item: BaseDataSourceItem) {
        guard let item = item as? Item, let id = item.id else { return }
        
        if item is PeopleItem {
            output.startAsyncOperation()
            
            peopleService.getPeopleAlbum(id: Int(id), success: { [weak self] album in
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
}

