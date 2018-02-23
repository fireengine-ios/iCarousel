//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderRouterInput.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol LBAlbumLikePreviewSliderRouterInput {

    func onItemSelected(_ item: SliderItem, moduleOutput: LBAlbumLikePreviewSliderModuleInput?)
    
    func goToAlbumbsGreedView()
    
}
