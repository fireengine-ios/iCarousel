//
//  PhotoVideoAlbumDetailInteractor.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 28.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoVideoAlbumDetailInteractor: PhotoVideoDetailInteractor {
    
    override func bottomBarConfig(for selectedIndex: Int) -> EditingBarConfig {
        let selectedItem = array[selectedIndex]
        switch selectedItem.fileType {
        case .image, .video:
            var barConfig = photoVideoBottomBarConfig!
            if selectedItem.isLocalItem {
                barConfig = EditingBarConfig(elementsConfig: barConfig.elementsConfig + [.sync], style: .black, tintColor: nil)
            } else {
                barConfig = EditingBarConfig(elementsConfig: barConfig.elementsConfig, style: .black, tintColor: nil)
            }
            
            if barConfig.elementsConfig.contains(.smash), (selectedItem.fileType == .video || selectedItem.name?.isNameExtensionGif() == true) {
                var newConfigElements = barConfig.elementsConfig
                newConfigElements.remove(.smash)
                barConfig = EditingBarConfig(elementsConfig: newConfigElements, style: .black, tintColor: nil)
            }
            
            return barConfig
        case .application:
            return documentsBottomBarConfig
        default:
            return photoVideoBottomBarConfig
        }
    }
    
    override func deletePhotosFromPeopleAlbum(items: [BaseDataSourceItem], id: Int64) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item] {
                self?.output.startAsyncOperation()

                PeopleService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] error in
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFailed(withType: .removeFromFaceImageAlbum)
                        }
                    }
                }
            }
        }
        
        output.didRemoveFromAlbum(completion: okHandler)
    }
    
    override func deletePhotosFromThingsAlbum(items: [BaseDataSourceItem], id: Int64) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item] {
                self?.output.startAsyncOperation()

                ThingsService().deletePhotosFromAlbum(id: id, photos: items, success: { [weak self] in
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] error in
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFailed(withType: .removeFromFaceImageAlbum)
                        }
                    }
                }
            }
        }
        
        output.didRemoveFromAlbum(completion: okHandler)
    }

    override func deletePhotosFromPlacesAlbum(items: [BaseDataSourceItem], uuid: String) {
        let okHandler: () -> Void = { [weak self] in
            if let items = items as? [Item] {
                self?.output.startAsyncOperation()
                
                PlacesService().deletePhotosFromAlbum(uuid: uuid, photos: items, success: { [weak self] in
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFinished(withType: .removeFromFaceImageAlbum, response: nil)
                        }
                    }
                }) { [weak self] error in
                    DispatchQueue.main.async {
                        if let output = self?.output as? BaseItemInputPassingProtocol {
                            output.operationFailed(withType: .removeFromFaceImageAlbum)
                        }
                    }
                }
            }
        }
        
        output.didRemoveFromAlbum(completion: okHandler)
    }
    
}
