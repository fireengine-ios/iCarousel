//
//  FaceImageItemsInteractor.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageItemsInteractor: BaseFilesGreedInteractor {
    
    private let peopleService = PeopleService()
    private let thingsService = ThingsService()
    private let placesService = PlacesService()
    
    override func imageForNoFileImageView() -> UIImage {
        if remoteItems is PeopleItemsService {
            return UIImage(named: "peopleNoPhotos")!
        } else if remoteItems is ThingsItemsService {
            return UIImage(named: "thingsNoPhotos")!
        } else if remoteItems is PlacesItemsService {
            return UIImage(named: "locationNoPhotos")!
        }
        
        return UIImage()
    }
    
    override func textForNoFileLbel() -> String {
        if remoteItems is PeopleItemsService {
            return TextConstants.faceImageNoPhotos
        } else if remoteItems is ThingsItemsService {
            return TextConstants.faceImageNoPhotos
        } else if remoteItems is PlacesItemsService {
            return TextConstants.faceImageNoPhotos
        }
        
        return ""
    }

}

// MARK: FaceImageItemsInteractorInput

extension FaceImageItemsInteractor: FaceImageItemsInteractorInput {
    
    func loadItem(_ item: BaseDataSourceItem) {
        
        guard let item = item as? Item, let id = item.id else { return }
        
        if let item = item as? PeopleItem {
            output.startAsyncOperation()
            
            peopleService.getPeopleAlbum(id: Int(id), success: { [weak self] album in
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    output.didLoadAlbum(album, forItem: item)
                }
                
                self?.output.asyncOperationSucces()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        } else if let item = item as? ThingsItem {
            output.startAsyncOperation()
            
            thingsService.getThingsAlbum(id: Int(id), success: { [weak self] album in
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    output.didLoadAlbum(album, forItem: item)
                }
                
                self?.output.asyncOperationSucces()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        } else if let item = item as? PlacesItem {
            output.startAsyncOperation()
            
            placesService.getPlacesAlbum(id: Int(id), success: { [weak self] album in
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    output.didLoadAlbum(album, forItem: item)
                }
                
                self?.output.asyncOperationSucces()
                }, fail: { [weak self] fail in
                    self?.output.asyncOperationFail(errorMessage: fail.description)
            })
        }
    }
    
    func onSaveVisibilityChanges(_ items: [PeopleItem]) {
        output.startAsyncOperation()
        
        peopleService.changePeopleVisibility(peoples: items, success: { [weak self] _ in
            if let output = self?.output as? FaceImageItemsInteractorOutput {
                output.didSaveChanges(items)
            }
            
            self?.output.asyncOperationSucces()
            }, fail: { [weak self] error in
                self?.output.asyncOperationFail(errorMessage: error.description)
        })
    }
    
}
