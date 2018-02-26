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
    
    override func deletePhotosFromPeopleAlbum(items: [BaseDataSourceItem], id: Int64) {
        if let items = items as? [Item] {
            PeopleService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                DispatchQueue.main.async {
                    if let output = self?.output as? BaseItemInputPassingProtocol {
                        output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                    }
                }
            }) { [weak self] (error) in
                DispatchQueue.main.async {
                    if let output = self?.output as? BaseItemInputPassingProtocol {
                        output.operationFailed(withType: .removeFromFaceImageAlbum)
                    }
                }
            }
        }
    }
    
    override func deletePhotosFromThingsAlbum(items: [BaseDataSourceItem], id: Int64) {
        if let items = items as? [Item] {
            ThingsService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                DispatchQueue.main.async {
                    if let output = self?.output as? BaseItemInputPassingProtocol {
                        output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                    }
                }
            }) { [weak self] (error) in
                DispatchQueue.main.async {
                    if let output = self?.output as? BaseItemInputPassingProtocol {
                        output.operationFailed(withType: .removeFromFaceImageAlbum)
                    }
                }
            }
        }
    }

    override func deletePhotosFromPlacesAlbum(items: [BaseDataSourceItem], id: Int64) {
        if let items = items as? [Item] {
            PlacesService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                DispatchQueue.main.async {
                    if let output = self?.output as? BaseItemInputPassingProtocol {
                        output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                    }
                }
            }) { [weak self] (error) in
                DispatchQueue.main.async {
                    if let output = self?.output as? BaseItemInputPassingProtocol {
                        output.operationFailed(withType: .removeFromFaceImageAlbum)
                    }
                }
            }
        }
    }
    
}
