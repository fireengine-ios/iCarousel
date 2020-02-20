//
//  PhotoVideoDetailPhotoVideoDetailViewInput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol PhotoVideoDetailViewInput: class {
    
    var status: ItemStatus { get set }
    
    func setupInitialState()
    
    func onShowSelectedItem(at index: Int, from items: [Item])
    
    func updateItems(objectsArray: [Item], selectedIndex: Int)
    
    func appendItems(_ items: [Item])
    
    func onLastRemoved()
    
    func getNavigationController() -> UINavigationController?
    
    func onItemSelected(at index: Int, from items: [Item])
    
    func hideView()
}
