//
//  PhotoVideoDetailPhotoVideoDetailInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PhotoVideoDetailInteractorOutput: AnyObject {
    
    func onShowSelectedItem(at index: Int, from items: [Item])
    
    func goBack()
    
    func updateItems(objects: [Item], selectedIndex: Int)
    
    func onLastRemoved()
    
    func startAsyncOperation()
    
    func cancelSave(use name: String)

    func cancelSaveDescription(use description: String)
    
    func updated()
    
    func failedUpdate(error: Error)
    
    func didValidateNameSuccess(name: String)

    func didValidateDescriptionSuccess(description: String)
    
    func updatePeople(items: [PeopleOnPhotoItemResponse])
    
    func didLoadAlbum(_ album: AlbumServiceResponse, forItem item: Item)
    
    func didFailedLoadAlbum(error: Error)
    
    func didLoadFaceRecognitionPermissionStatus(_ isPermitted: Bool)
    
    func updateItem(_ item: WrapData)

    @available(iOS 13.0, *)
    func setCurrentActivityItemsConfiguration(_ config: UIActivityItemsConfiguration?)
}
