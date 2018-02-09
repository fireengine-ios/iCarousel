//
//  FaceImagePhotosRouterInput.swift
//  Depo_LifeTech
//
//  Created by Constantine N on 2/5/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol FaceImagePhotosRouterInput {
    func openChangeCoverWith(_ albumUUID: String)
    func openAddName(_ item: WrapData, moduleOutput: FaceImagePhotosModuleOutput?)
}
