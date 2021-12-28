//
//  FaceImageChangeCoverInteractor.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageChangeCoverInteractor: BaseFilesGreedInteractor {
    
    let albumService = PhotosAlbumService()
    var personItem: Item? = nil
    
}

// MARK: - FaceImageChangeCoverInteractorInput

extension FaceImageChangeCoverInteractor: FaceImageChangeCoverInteractorInput {
    func setPersonThumbnailWith(item: BaseDataSourceItem) {
        guard let selectedItem = item as? Item, let personId = self.personItem?.id else { return }
        let params = PeopleChangeThumbnailParameters(personId: personId, item: selectedItem)
        
        albumService.changePeopleThumbnail(parameters: params, success: { [weak self] in
            self?.output.asyncOperationSuccess()
            if let output = self?.output as? FaceImageChangeCoverInteractorOutput {
                output.didSetPersonThumbnail(item: item)
            }
            ItemOperationManager.default.updatedPersonThumbnail(item: item)
            }, fail: { [weak self] error in
                self?.output.asyncOperationFail(errorMessage: localized(.changePersonThumbnailError))
        })
    }
    
    
    func setAlbumCoverWithItem(_ item: BaseDataSourceItem) {
        guard let remoteItems = remoteItems as? FaceImageDetailService else {
            return
        }
        output.startAsyncOperation()
        let params = ChangeCoverPhoto(albumUUID: remoteItems.albumUUID,
                                      photoUUID: item.uuid)
        albumService.changeCoverPhoto(parameters: params, success: { [weak self] in
            self?.output.asyncOperationSuccess()
            if let output = self?.output as? FaceImageChangeCoverInteractorOutput {
                output.didSetCover(item: item)
            }
            ItemOperationManager.default.updatedAlbumCoverPhoto(item: item)
            }, fail: { [weak self] error in
                self?.output.asyncOperationFail(errorMessage: localized(.changeAlbumCoverFail))
        })
    }
    
}
