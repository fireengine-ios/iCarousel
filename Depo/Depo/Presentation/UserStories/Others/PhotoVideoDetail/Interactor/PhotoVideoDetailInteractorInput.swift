//
//  PhotoVideoDetailPhotoVideoDetailInteractorInput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PhotoVideoDetailInteractorInput {
    
    typealias Item = WrapData
    
    func onSelectItem(fileObject:Item, from items:[Item])
    
    func onViewIsReady()
    
    func setSelectedItemIndex(selectedIndex: Int)
    
    var currentItemIndex: Int { get }
    
    var allItems: [Item] { get }

    var bottomBarConfig: EditingBarConfig { get }

    func deleteSelectedItem()
    
}
