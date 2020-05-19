//
//  PhotoVideoDetailPhotoVideoDetailInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PhotoVideoDetailInteractorOutput: class {
    
    func onShowSelectedItem(at index: Int, from items: [Item])
    
    func goBack()
    
    func updateItems(objects: [Item], selectedIndex: Int)
    
    func onLastRemoved()
    
    func startAsyncOperation()
    
    func cancelSave(use name: String)
    
    func updated()
    
    func failedUpdate(error: Error)
    
    func didValidateNameSuccess(name: String)
    
    func updatePeople(items: [PeopleOnPhotoItemResponse])
    
    func setHiddenPeoplePlaceholder(isHidden: Bool)
    
    func didLoadAlbum(_ album: AlbumServiceResponse, forItem item: Item)
    
    func hasPermissionFaceRecognition(_ bool: Bool)
}
