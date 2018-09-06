//
//  UploadFromLifeBoxUploadFromLifeBoxInteractor.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFromLifeBoxInteractor: BaseFilesGreedInteractor, UploadFromLifeBoxInteractorInput {
    
    var rootFolderUUID: String = ""
    
    func onUploadItems(items: [Item]) {
        let router = RouterVC()
        if router.isRootViewControllerAlbumDetail() {
            let parameter = AddPhotosToAlbum(albumUUID: rootFolderUUID, photos: items)
            PhotosAlbumService().addPhotosToAlbum(parameters: parameter, success: { [weak self] in
                DispatchQueue.main.async {
                    if let `self` = self {
                        self.output.asyncOperationSucces()
                        guard let out = self.output as? UploadFromLifeBoxInteractorOutput else {
                            return
                        }
                        out.uploadOperationSuccess()
                    }
                    ItemOperationManager.default.filesAddedToAlbum()
                }
            }, fail: { [weak self] error in
                DispatchQueue.main.async {
                    if let `self` = self {
                        self.output.asyncOperationFail(errorMessage: TextConstants.failWhileAddingToAlbum)
                    }
                }
            })
        } else {
            let itemsUUIDs = items.map({ $0.uuid })
            let parametr = CopyFiles(items: itemsUUIDs, path: rootFolderUUID)
            FileService().copy(copyparam: parametr, success: { [weak self] in
                DispatchQueue.main.async {
                    if let `self` = self {
                        self.output.asyncOperationSucces()
                        guard let out = self.output as? UploadFromLifeBoxInteractorOutput else {
                            return
                        }
                        out.uploadOperationSuccess()
                        ItemOperationManager.default.filesUpload(count: itemsUUIDs.count, toFolder: self.rootFolderUUID)
                    }
                }
            }, fail: { [weak self] fail in
                DispatchQueue.main.async {
                    if let `self` = self {
                        guard let out = self.output as? UploadFromLifeBoxInteractorOutput else {
                            self.output.asyncOperationFail(errorMessage: fail.description)
                            return
                        }
                        out.asyncOperationFail(errorResponse: fail)
                    }
                }
            })
        }
    }
    
}

final class UploadFromLifeBoxFavoritesInteractor: UploadFromLifeBoxInteractor {
    
    private lazy var fileService = WrapItemFileService()
    
    override func onUploadItems(items: [Item]) {
        fileService.addToFavourite(files: items, success: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.output.asyncOperationSucces()
                guard let output = self?.output as? UploadFromLifeBoxInteractorOutput else {
                    return
                }
                output.uploadOperationSuccess()
                ItemOperationManager.default.addFilesToFavorites(items: items)
            }
        }, fail: { [weak self] error in
            DispatchQueue.main.async {
                self?.output.asyncOperationFail(errorMessage: error.description)
            }
        })
    }
    
}
