//
//  BottomSelectionTabBarBottomSelectionTabBarRouterInput.swift
//  Depo
//
//  Created by AlexanderP on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol BottomSelectionTabBarRouterInput {
    
    func onInfo(object: Item)
    
    func addToAlbum(items: [BaseDataSourceItem])
    
    func showPrint(items: [BaseDataSourceItem])
    
    func showSelectFolder(selectFolder: SelectFolderViewController)
    
    func showShare(rect: CGRect?, urls: [String])
    
    func showDeleteMusic(_ completion: @escaping VoidHandler)
    
    func showErrorShareEmptyAlbums()
}
