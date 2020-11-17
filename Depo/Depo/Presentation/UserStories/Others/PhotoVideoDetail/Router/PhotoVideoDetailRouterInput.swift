//
//  PhotoVideoDetailPhotoVideoDetailRouterInput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PhotoVideoDetailRouterInput {
    
    func onInfo(object: Item)
    
    func goBack(navigationConroller: UINavigationController?)
    
    func showConfirmationPopup(completion: @escaping () -> ())
    
    func goToPremium()
    
    func openFaceImageItemPhotosWith(_ item: Item, album: AlbumItem, moduleOutput: FaceImageItemsModuleOutput?)
 
    func openPrivateShare(for item: Item, completion: @escaping BoolHandler)
}
