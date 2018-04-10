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
            guard accessGranted else {
                return
            }
            
            log.debug("UploadFilesSelectionInteractor getAllItems LocalMediaStorage askPermissionForPhotoFramework")
            
            let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [uuid], options: nil)
            
            if let album = collectionFetchResult.firstObject {
                let assetsFetchResult = PHAsset.fetchAssets(in: album, options: nil)
                var assets = [PHAsset]()
                assetsFetchResult.enumerateObjects({ asset, index, stop in
                    assets.append(asset)
                })
                
                var items = CoreDataStack.default.allLocalItems(with: assets.map({ $0.localIdentifier }))

                items.sort {
                    guard let firstDate = $0.creationDate else {
                        return false
                    }
                    guard let secondDate = $1.creationDate else {
                        return true
                    }
                    
                    return firstDate > secondDate
                }
                
                self?.output.getContentWithSuccess(array: [items])
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
        
        UploadService.default.uploadFileList(items: uploadItems, uploadType: .fromHomePage, uploadStategy: .WithoutConflictControl, uploadTo: .MOBILE_UPLOAD, folder: rooutUUID, isFavorites: isFavorites, isFromAlbum: isFromAlbum, success: { [weak self] in
            log.debug("UploadFilesSelectionInteractor addToUploadOnDemandItems UploadService uploadFileList success")

            self?.output.asyncOperationSucces()
        }, fail: { [weak self] errorResponse in
            log.debug("UploadFilesSelectionInteractor addToUploadOnDemandItems UploadService uploadFileList fail")
            UIApplication.showOnTabBar(errorMessage: errorResponse.errorDescription)
            self?.output.asyncOperationSucces()
        })
    }
}
