//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderInteractorInput.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LBAlbumLikePreviewSliderInteractorInput {
        
    func requestAllItems()
    
    var albumItems: [AlbumItem] { get set }
    var storyItems: [Item] { get set }
    var peopleItems: [Item] { get set }
    var thingItems: [Item] { get set }
    var placeItems: [Item] { get set }

}
