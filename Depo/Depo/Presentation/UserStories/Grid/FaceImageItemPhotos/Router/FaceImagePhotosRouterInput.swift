//
//  FaceImagePhotosRouterInput.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol FaceImagePhotosRouterInput {
    func openAddName(_ item: WrapData, moduleOutput: FaceImagePhotosModuleOutput?, isSearchItem: Bool)
    func openChangeCoverWith(_ albumUUID: String, moduleOutput: FaceImageChangeCoverModuleOutput)
}
