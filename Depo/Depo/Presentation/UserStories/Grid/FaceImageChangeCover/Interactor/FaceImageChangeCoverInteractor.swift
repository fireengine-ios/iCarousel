//
//  FaceImageChangeCoverInteractor.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

class FaceImageChangeCoverInteractor: BaseFilesGreedInteractor, FaceImageChangeCoverInteractorInput {
    
    let albumService = PhotosAlbumService()
    
    func setAlbumCoverWithItem(_ item: BaseDataSourceItem) {
        guard let remoteItems = remoteItems as? FaceImageDetailService else {
            return
        }
        output.startAsyncOperation()
        let params = ChangeCoverPhoto(albumUUID: remoteItems.albumUUID,
                                      photoUUID: item.uuid)
        albumService.changeCoverPhoto(parameters: params, success: { [weak self] in
            self?.output.asyncOperationSucces()
            if let output = self?.output as? FaceImageChangeCoverInteractorOutput {
                output.didSetCover(item: item)
            }
        }) { [weak self] (error) in
            self?.output.asyncOperationFail(errorMessage: error.description)
        }
        
    }
}
