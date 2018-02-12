//
//  PhotoVideoAlbumDetailInteractor.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 28.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoVideoAlbumDetailInteractor: PhotoVideoDetailInteractor {

    override var bottomBarConfig: EditingBarConfig {
        let selectedItem = array[selectedIndex]
        switch selectedItem.fileType {
        case .image, .video:
            var barConfig = photoVideoBottomBarConfig!
            if selectedItem.isLocalItem {
                barConfig = EditingBarConfig(elementsConfig: barConfig.elementsConfig + [.sync], style: .black, tintColor: nil)
            } else {
                barConfig = EditingBarConfig(elementsConfig: barConfig.elementsConfig + [.download], style: .black, tintColor: nil)
            }
            return barConfig
        case .application:
            return documentsBottomBarConfig
        default:
            return photoVideoBottomBarConfig
        }
    }
    
}
