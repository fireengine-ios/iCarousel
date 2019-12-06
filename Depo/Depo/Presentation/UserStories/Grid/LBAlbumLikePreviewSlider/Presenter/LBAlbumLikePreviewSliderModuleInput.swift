//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderModuleInput.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LBAlbumLikePreviewSliderModuleInput: class {

    func reloadAll()
    func reload(types: [MyStreamType])
    func countThumbnailsFor(type: MyStreamType) -> Int
}
