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
    
    func updateItems(objects: [Item], selectedIndex: Int, isRightSwipe: Bool)
    
    func onLastRemoved()
    
    func startAsyncOperation()
}
