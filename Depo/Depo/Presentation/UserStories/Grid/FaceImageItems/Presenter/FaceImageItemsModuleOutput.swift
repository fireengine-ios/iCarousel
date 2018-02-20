//
//  FaceImageItemsModuleOutput.swift
//  Depo
//
//  Created by Harhun Brothers on 09.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol FaceImageItemsModuleOutput: class {
    func didChangeName(item: WrapData)
    func didReloadData()
    func delete(item: Item)
}
