//
//  FaceImageItemsRouterInput.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol FaceImageItemsRouterInput {
    func openFaceImageItemPhotosWith(_ item: Item, album: AlbumItem, moduleOutput: FaceImageItemsModuleOutput?)
    func showPopUp()
    func showNoDetailsAlert(with message: String)
    func openPremium(source: BecomePremiumViewSourceType, module: FaceImageItemsModuleOutput)
    
    func display(error: String)
}
