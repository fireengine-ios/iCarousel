//
//  FaceImageItemsInteractor.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

class FaceImageItemsInteractor: BaseFilesGreedInteractor, FaceImageItemsInteractorInput {
    
    let peopleService = PeopleService()
    let thingsService = ThingsService()
    let placesService = PlacesService()
    
    // MARK: - FaceImageItemsInteractorInput
    
    func loadItem(_ item: BaseDataSourceItem) {
        
        guard let item = item as? Item, let id = item.id else { return }
        
        if let item = item as? PeopleItem {
//            output.startAsyncOperation()
//            peopleService.getPeopleAlbum(id: Int(id), success: { [weak self] (uuid) in
//                if let output = self?.output as? FaceImageItemsInteractorOutput {
//                    output.didLoadAlbum(uuid, forItem: item)
//                }
//                self?.output.asyncOperationSucces()
//            }, fail: { [weak self] (error) in
//                self?.output.asyncOperationFail(errorMessage: error.description)
//            })
            
            peopleService.getAlbumsForPeopleItemWithID(Int(id), success: { (response) in
                
            }, fail: { (error) in
                
            })
        } else if let item = item as? ThingsItem {
            output.startAsyncOperation()
            thingsService.getThingsAlbum(id: Int(id), success: { [weak self] (album) in
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    output.didLoadAlbum(album, forItem: item)
                }
                self?.output.asyncOperationSucces()
                }, fail: { [weak self] (error) in
                    self?.output.asyncOperationFail(errorMessage: error.description)
            })
        } else if let item = item as? PlacesItem {
            output.startAsyncOperation()
            placesService.getPlacesAlbum(id: Int(id), success: { [weak self] (album) in
                if let output = self?.output as? FaceImageItemsInteractorOutput {
                    output.didLoadAlbum(album, forItem: item)
                }
                self?.output.asyncOperationSucces()
                }, fail: { [weak self] (error) in
                    self?.output.asyncOperationFail(errorMessage: error.description)
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
        }) { [weak self] (error) in
            self?.output.asyncOperationFail(errorMessage: error.description)
        }
    }
}
