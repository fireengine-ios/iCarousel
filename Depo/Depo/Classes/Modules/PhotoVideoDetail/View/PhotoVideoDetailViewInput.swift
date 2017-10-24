//
//  PhotoVideoDetailPhotoVideoDetailViewInput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PhotoVideoDetailViewInput: class {

    typealias Item = WrapData
    
    func setupInitialState()
    
    func onShowSelectedItem(at index: Int, from items:[Item])
    
    func updateItems(objectsArray: [Item], selectedIndex: Int)
    
    func getNavigationController() -> UINavigationController?
    
}
