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
    
    func trackVideoStart()
    func trackVideoStop()
    
    func replaceUploaded(_ item: WrapData)
    
    func updateExpiredItem(_ item: WrapData)
    
    func appendItems(_ items: [Item])
    
    func onRename(newName: String)
    
    func onValidateName(newName: String)
    
    func createNewUrl()
}
