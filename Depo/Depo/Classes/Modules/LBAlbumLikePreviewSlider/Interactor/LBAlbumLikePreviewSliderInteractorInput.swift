//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderInteractorInput.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LBAlbumLikePreviewSliderInteractorInput {

    var currentItems: [AlbumItem] { get set }
    
    func requestAlbumbs()
    
}
