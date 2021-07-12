//
//  FaceImagePhotosModuleOutput.swift
//  Depo
//
//  Created by Harhun Brothers on 09.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

protocol FaceImagePhotosModuleOutput: AnyObject {
    func didChangeName(item: WrapData)
    func didMergePeople()
    func didMergeAfterSearch(item: Item)
    func getSliderItmes(items: [SliderItem])
}
