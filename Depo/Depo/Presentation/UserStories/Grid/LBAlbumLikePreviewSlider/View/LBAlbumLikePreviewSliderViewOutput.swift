//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderViewOutput.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol LBAlbumLikePreviewSliderViewOutput {

    func viewIsReady()

    func previewItems(withType type: MyStreamType) -> [Item]
    
    func sliderTitlePressed()
    
    func onSelectItem(type: MyStreamType)
    
    func reloadData()

}
