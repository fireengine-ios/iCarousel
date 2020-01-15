//
//  PhotoVideoAlbumDetailInteractor.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 28.11.2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhotoVideoAlbumDetailInteractor: PhotoVideoDetailInteractor {
    
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
