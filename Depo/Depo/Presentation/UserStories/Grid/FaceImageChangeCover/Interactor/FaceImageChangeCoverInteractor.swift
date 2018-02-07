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
    
    func setAlbumCoverWithPhoto(_ photoUUID: String) {
        guard let remoteItems = remoteItems as? FaceImageDetailService else {
            return
        }
        output.startAsyncOperation()
        let params = ChangeCoverPhoto(albumUUID: remoteItems.albumUUID,
                                      photoUUID: photoUUID)
        albumService.changeCoverPhoto(parameters: params, success: { [weak self] in
            self?.output.asyncOperationSucces()
            if let output = self?.output as? FaceImageChangeCoverInteractorOutput {
                output.didSetCover()
            }
        }) { [weak self] (error) in
            self?.output.asyncOperationFail(errorMessage: error.description)
        }
        
    }
}
