//
//  FaceImageAddNameRouterInput.swift
//  Depo
//
//  Created by Harhun Brothers on 09.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol FaceImageAddNameRouterInput {
    func popToPeopleItems()
    func showMerge(firstUrl: URL, secondUrl: URL, completion: @escaping VoidHandler)
}
