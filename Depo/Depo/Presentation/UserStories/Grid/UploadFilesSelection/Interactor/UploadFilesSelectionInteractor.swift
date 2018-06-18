//
//  UploadFilesSelectionUploadFilesSelectionInteractor.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Photos

class UploadFilesSelectionInteractor: BaseFilesGreedInteractor {

    weak var uploadOutput: UploadFilesSelectionInteractorOutput?
    var rootUIID: String?
    
    let localMediaStorage = LocalMediaStorage.default
    
    override func getAllItems(sortBy: SortedRules) {
        log.debug("UploadFilesSelectionInteractor getAllItems")

        guard let uuid = rootUIID else {
            return
        }
        
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: true) {[weak self] accessGranted, _ in
            log.debug("UploadFilesSelectionInteractor getAllItems LocalMediaStorage askPermissionForPhotoFramework")
            guard accessGranted else {
                return
            }
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [uuid], options: nil)
                
                if let album = collectionFetchResult.firstObject {
                    let assetsFetchResult = PHAsset.fetchAssets(in: album, options: nil)
                    var assets = [PHAsset]()
                    assetsFetchResult.enumerateObjects({ asset, index, stop in
                        assets.append(asset)
                    })
                    
                    var items = CoreDataStack.default.allLocalItems(with: assets)
                    
                    items.sort {
                        guard let firstDate = $0.creationDate else {
                            return false
                        }
                        guard let secondDate = $1.creationDate else {
                            return true
                        }
                        
                        return firstDate > secondDate
                    }
                    
                    DispatchQueue.main.async {
                        self?.output.getContentWithSuccess(array: [items])
                    }
                }
            }
        }
    }
    
    func addToUploadOnDemandItems(items: [BaseDataSourceItem]) {
        log.debug("UploadFilesSelectionInteractor addToUploadOnDemandItems")

        let uploadItems = items as! [WrapData]
        let router = RouterVC()
        let isFavorites = router.isOnFavoritesView()
        let rooutUUID = router.getParentUUID()
        let isFromAlbum = router.isRootViewControllerAlbumDetail()
        
        if isFromAlbum {
            ItemOperationManager.default.startUploadFilesToAlbum(files: uploadItems)
        }
        
        if let errorMessage = verify(items: uploadItems) {
            uploadOutput?.addToUploadFailedWith(errorMessage: errorMessage)
            return
        }
        
        UploadService.default.uploadFileList(items: uploadItems, uploadType: .fromHomePage, uploadStategy: .WithoutConflictControl, uploadTo: .MOBILE_UPLOAD, folder: rooutUUID, isFavorites: isFavorites, isFromAlbum: isFromAlbum, success: { [weak self] in
            log.debug("UploadFilesSelectionInteractor addToUploadOnDemandItems UploadService uploadFileList success")

            DispatchQueue.main.async {
                self?.uploadOutput?.addToUploadSuccessed()
            }
        }, fail: { [weak self] errorResponse in
            log.debug("UploadFilesSelectionInteractor addToUploadOnDemandItems UploadService uploadFileList fail")
            DispatchQueue.main.async {
                self?.uploadOutput?.addToUploadFailedWith(errorMessage: errorResponse.description)
            }
            }, returnedUploadOperation: {_ in})
    }
    
    fileprivate func verify(items: [WrapData]) -> String? {
        guard !items.isEmpty else {
            return TextConstants.uploadFromLifeBoxNoSelectedPhotosError
        }
        
        var filteredItems = items.filter { $0.fileSize < NumericConstants.fourGigabytes }
        guard !filteredItems.isEmpty else {
            return TextConstants.syncFourGbVideo
        }
        
        let freeDiskSpaceInBytes = Device.getFreeDiskSpaceInBytes()
        filteredItems = filteredItems.filter { $0.fileSize < freeDiskSpaceInBytes }
        guard !filteredItems.isEmpty else {
            return TextConstants.syncNotEnoughMemory
        }
        
        return nil
    }
}
