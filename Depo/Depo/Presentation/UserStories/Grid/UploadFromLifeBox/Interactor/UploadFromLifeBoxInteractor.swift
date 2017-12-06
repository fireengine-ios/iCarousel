//
//  UploadFromLifeBoxUploadFromLifeBoxInteractor.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFromLifeBoxInteractor: BaseFilesGreedInteractor, UploadFromLifeBoxInteractorInput {
    
    var rootFolderUUID: String = ""
    
    func onUploadItems(items: [Item]){
        let router = RouterVC()
        if router.isRootViewControllerAlbumDetail(){
            let parameter = AddPhotosToAlbum(albumUUID: rootFolderUUID, photos: items)
            PhotosAlbumService().addPhotosToAlbum(parameters: parameter, success: { [weak self] in
                if let self_ = self {
                    self_.output.asyncOperationSucces()
                    
                    guard let out = self_.output as? UploadFromLifeBoxInteractorOutput else{
                        return
                    }
                    out.uploadOperationSuccess()
                }
            }, fail: { [weak self] (error) in
                if let self_ = self {
                    self_.output.asyncOperationFail(errorMessage: TextConstants.failWhileAddingToAlbum)
                }
            })
        }else{
            let itemsUUIDs = items.map({ $0.uuid })
            let parametr = CopyFiles(items: itemsUUIDs, path: rootFolderUUID)
            FileService().copy(copyparam: parametr, success: { [weak self] in
                if let self_ = self {
                    self_.output.asyncOperationSucces()
                    guard let out = self_.output as? UploadFromLifeBoxInteractorOutput else{
                        return
                    }
                    out.uploadOperationSuccess()
                }
            }, fail: { [weak self] (fail) in
                if let self_ = self {
                    self_.output.asyncOperationFail(errorMessage: TextConstants.failWhileuploadFromLifeBoxCopy)
                }
            })
        }
    }
    
}
