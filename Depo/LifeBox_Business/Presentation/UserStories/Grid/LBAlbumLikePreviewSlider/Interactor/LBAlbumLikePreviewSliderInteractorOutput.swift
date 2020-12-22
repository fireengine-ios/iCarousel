//
//  LBAlbumLikePreviewSliderLBAlbumLikePreviewSliderInteractorOutput.swift
//  Depo
//
//  Created by AlexanderP on 21/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol LBAlbumLikePreviewSliderInteractorOutput: class {

    func operationSuccessed(withItems items: [SliderItem])
    func operationFailed()
    
}
