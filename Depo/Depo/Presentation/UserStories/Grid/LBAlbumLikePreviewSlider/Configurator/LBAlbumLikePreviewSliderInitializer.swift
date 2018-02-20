//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderInitializer.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LBAlbumLikePreviewSliderModuleInitializer: NSObject {

    let lbAlbumLikeSliderVC = LBAlbumLikePreviewSliderViewController.initFromXIB()
    
    var lbAlbumLikeSliderPresenter: LBAlbumLikePreviewSliderPresenter?
    
    func initialise(inputPresenter: LBAlbumLikePreviewSliderPresenter?, peopleItem: PeopleItem? = nil, moduleOutput: FaceImagePhotosModuleOutput? = nil) {
        lbAlbumLikeSliderPresenter = inputPresenter
        let configurator = LBAlbumLikePreviewSliderModuleConfigurator()
        configurator.configureModuleForViewInput(viewInput: lbAlbumLikeSliderVC, inputPresenter: inputPresenter, peopleItem: peopleItem, moduleOutput: moduleOutput)
    }
}
