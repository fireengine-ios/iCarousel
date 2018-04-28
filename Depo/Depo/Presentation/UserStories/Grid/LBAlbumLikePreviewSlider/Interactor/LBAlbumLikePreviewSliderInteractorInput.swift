//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderInteractorInput.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LBAlbumLikePreviewSliderInteractorInput {
        
    func requestAllItems()
    
    func reload(type: MyStreamType) 
    
    var currentItems: [SliderItem] { get set }
   
}
