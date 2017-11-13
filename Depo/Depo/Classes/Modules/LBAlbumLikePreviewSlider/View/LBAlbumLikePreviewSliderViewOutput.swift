//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LBAlbumLikePreviewSliderViewOutput {

    func viewIsReady()
    
    var currentItems: [AlbumItem] { get }
    
    func sliderTitlePressed()
    
    func onSelectAlbumAt(index: Int)
    
    func reloadData()

}
