//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderModuleInput.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LBAlbumLikePreviewSliderModuleInput: class {

    func setup(withItems albumItems: [AlbumItem], storyItems: [Item], peopleItems: [Item], thingItems: [Item], placeItems: [Item])
    func reload()
}
