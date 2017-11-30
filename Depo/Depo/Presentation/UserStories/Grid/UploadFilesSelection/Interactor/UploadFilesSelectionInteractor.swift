//
//  UploadFilesSelectionUploadFilesSelectionInteractor.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Photos

class UploadFilesSelectionInteractor: BaseFilesGreedInteractor {

    var uploadOutput: UploadFilesSelectionInteractorOutput?
    var rootUIID: String?
    
    let localMediaStorage = LocalMediaStorage.default
    
    override func getAllItems(sortBy: SortedRules) {
        guard let uuid = rootUIID else {
            return
        }
        
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: true) {[weak self] (accessGranted, _) in
            guard accessGranted else {
                return
            }
            
            let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [uuid], options: nil)
            if let album = collectionFetchResult.firstObject {
                let assetsFetchResult = PHAsset.fetchAssets(in: album, options: nil)
                var assets = [PHAsset]()
                assetsFetchResult.enumerateObjects({ (asset, index, stop) in
                    assets.append(asset)
                })
                var items = [WrapData]()
                for asset in assets {
                    if let info = self?.localMediaStorage.fullInfoAboutAsset(asset: asset) {
                        let baseMediaContent = BaseMediaContent(curentAsset: asset,
                                                                urlToFile: info.url,
                                                                size: info.size,
                                                                md5: info.md5)
                        items.append(WrapData(baseModel: baseMediaContent))
                    }
                }
                
                for item in items {
                    item.isLocalItem = false
                }
                
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
    
    func addToUploadOnDemandItems(items: [BaseDataSourceItem]){
        let uploadItems = items as! [WrapData]
        let router = RouterVC()
        let isFavorites = router.isOnFavoritesView()
        let rooutUUID = router.getParentUUID()
        let isFromAlbum = router.isRootViewControllerAlbumDetail()
        UploadService.default.uploadFileList(items: uploadItems, uploadType: .fromHomePage, uploadStategy: .WithoutConflictControl, uploadTo: .MOBILE_UPLOAD, folder: rooutUUID, isFavorites: isFavorites, isFromAlbum: isFromAlbum, success: {
            self.output.asyncOperationSucces()
        }) { (errorResponse) in
            self.output.asyncOperationSucces()
        }
//        UploadService.default.uploadOnDemandFileList(items: uploadItems,
//                                                     uploadType: .autoSync,
//                                                     uploadStategy: .WithoutConflictControl,
//                                                     uploadTo: .MOBILE_UPLOAD,
//                                                     folder: rootUIID ?? "")
    }
}

