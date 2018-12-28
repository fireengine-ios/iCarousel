//
//  MyStorageRouterInput.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol MyStorageRouterInput {
    func showCancelOfferAlert(with text: String)
    func showCancelOfferApple()
    func showSubTurkcellOpenAlert(with text: String)
    
    func display(error: String)
}
