//
//  PhotoVideoDetailPhotoVideoDetailInteractorInput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PhotoVideoDetailInteractorInput: class {
    
    func onSelectItem(fileObject: Item, from items: [Item])
    
    func onViewIsReady()
    
    var currentItemIndex: Int? { get set }
    
    var allItems: [Item] { get }

    func bottomBarConfig(for selectedIndex: Int) -> EditingBarConfig

    func deleteSelectedItem(type: ElementTypes)
    
    var setupedMoreMenuConfig: [ElementTypes] { get }
    
    func deletePhotosFromPeopleAlbum(items: [BaseDataSourceItem], id: Int64)
    func deletePhotosFromThingsAlbum(items: [BaseDataSourceItem], id: Int64)
    func deletePhotosFromPlacesAlbum(items: [BaseDataSourceItem], uuid: String)
    
    func trackVideoStart()
    func trackVideoStop()
    
    func replaceUploaded(_ item: WrapData)
}
