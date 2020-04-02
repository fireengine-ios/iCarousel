//
//  UploadFromLifeBoxUploadFromLifeBoxInteractor.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFromLifeBoxInteractor: BaseFilesGreedInteractor, UploadFromLifeBoxInteractorInput {
    
    private let albumService = PhotosAlbumService()
    private var getNextPageRetryCounter = 0
    private var numberOfRetries = 3
    var rootFolderUUID: String = ""
    
    func onUploadItems(items: [Item]) {
        let router = RouterVC()
        if router.isRootViewControllerAlbumDetail() {
            let parameter = AddPhotosToAlbum(albumUUID: rootFolderUUID, photos: items)
            albumService.addPhotosToAlbum(parameters: parameter, success: { [weak self] in
                DispatchQueue.main.async {
                    if let `self` = self {
                        self.output.asyncOperationSuccess()
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
                        self.output.asyncOperationSuccess()
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
    
    override func reloadItems(_ searchText: String!, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        debugLog("UploadFromLifeBoxInteractor reloadItems")
        
        guard isUpdating == false else {
            return
        }
        isUpdating = true
        getNextPageRetryCounter += 1
        remoteItems.reloadUnhiddenItems(sortBy: sortBy, sortOrder: sortOrder, success: { [weak self] items in
            self?.getNextPageRetryCounter = 0
            DispatchQueue.main.async {
                debugLog("UploadFromLifeBoxInteractor reloadItems RemoteItemsService reloadItems success")
                
                var isArrayPresenter = false
                if let presenter = self?.output as? BaseFilesGreedPresenter {
                    isArrayPresenter = presenter.isArrayDataSource()
                }
                
                self?.isUpdating = false
                guard let output = self?.output else { return }
                if items.count == 0 {
                    output.getContentWithSuccessEnd()
                } else if isArrayPresenter {
                    var array = [[WrapData]]()
                    array.append(items)
                    output.getContentWithSuccess(array: array)
                } else if items.count > 0 {
                    output.getContentWithSuccess(items: items)
                }
            }
            }, fail: { [weak self] in
                debugLog("UploadFromLifeBoxInteractor reloadItems RemoteItemsService reloadItems fail")
                guard let `self` = self, let output = self.output else {
                    return
                }
                if self.getNextPageRetryCounter >= self.numberOfRetries {
                    self.getNextPageRetryCounter = 0
                    self.isUpdating = false
                    output.getContentWithFail(errorString: nil)
                } else {
                    self.isUpdating = false
                    self.remoteItems.cancellAllRequests()
                    self.reloadItems(searchText, sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
                }

            },
               newFieldValue: newFieldValue)
    }
    
    override func nextItems(_ searchText: String! = nil, sortBy: SortType, sortOrder: SortOrder, newFieldValue: FieldValue?) {
        debugLog("UploadFromLifeBoxInteractor nextItems")

        guard isUpdating == false else {
            return
        }
        isUpdating = true
        getNextPageRetryCounter += 1
        remoteItems.nextUnhiddenItems(sortBy: sortBy,
                              sortOrder: sortOrder,
                              success: { [weak self] items in
                self?.getNextPageRetryCounter = 0
                DispatchQueue.main.async {
                    debugLog("UploadFromLifeBoxInteractor nextItems RemoteItemsService reloadItems success")

                    self?.isUpdating = false
                    guard let output = self?.output else { return }
                    if items.count == 0 {
                        output.getContentWithSuccessEnd()
                    } else if items.count > 0 {
                        output.getContentWithSuccess(items: items)
                    }
                }
            }, fail: { [weak self] in
                debugLog("UploadFromLifeBoxInteractor nextItems RemoteItemsService reloadItems fail")
                guard let `self` = self, let output = self.output else {
                    return
                }
                if self.getNextPageRetryCounter >= self.numberOfRetries {
                    self.getNextPageRetryCounter = 0
                    self.isUpdating = false
                    output.getContentWithFail(errorString: nil)
                } else {
                    self.isUpdating = false
                    self.remoteItems.cancellAllRequests()
                    self.nextItems(sortBy: sortBy, sortOrder: sortOrder, newFieldValue: newFieldValue)
                }
        }, newFieldValue: newFieldValue)
    }
}

final class UploadFromLifeBoxFavoritesInteractor: UploadFromLifeBoxInteractor {
    
    private lazy var fileService = WrapItemFileService()
    
    override func onUploadItems(items: [Item]) {
        fileService.addToFavourite(files: items, success: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.output.asyncOperationSuccess()
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
