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
        debugLog("UploadFilesSelectionInteractor getAllItems")

        guard let uuid = rootUIID else {
            return
        }
        
        localMediaStorage.askPermissionForPhotoFramework(redirectToSettings: true) { [weak self] accessGranted, _ in
            debugLog("UploadFilesSelectionInteractor getAllItems LocalMediaStorage askPermissionForPhotoFramework")
            guard accessGranted else {
                return
            }
            self?.output.startAsyncOperation()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [uuid], options: nil)
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                if let album = collectionFetchResult.firstObject {
                    let assetsFetchResult = PHAsset.fetchAssets(in: album, options: options)
                    var assets = [PHAsset]()
                    assetsFetchResult.enumerateObjects({ asset, index, stop in
                        assets.append(asset)
                    })
                    
                    guard !CacheManager.shared.isPreparing else {
                        self?.getAllRelatedItemsPageFromPH(assets: assets)
                       return
                    }
                    self?.getAllRelatedItemsFromDataBase(assets: assets){ [weak self] items in
                        DispatchQueue.main.async {
                            self?.output.getContentWithSuccess(array: [items])
                        }
                    }
                }
            }
        }
    }
    
    private let pageSize: Int = 100
    
    private func getAllRelatedItemsPageFromPH(assets: [PHAsset]) {
        guard !assets.isEmpty else {
            uploadOutput?.newLocalItemsReceived(newItems:[])
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard CacheManager.shared.isPreparing else {
                self?.getAllRelatedItemsFromDataBase(assets: assets) { [weak self] dataBaseStoredLocalas in
                    DispatchQueue.main.async {
                        self?.uploadOutput?.newLocalItemsReceived(newItems: dataBaseStoredLocalas)
                    }
                }
                return
            }
            let nextItemsToSave = Array(assets.prefix(NumericConstants.numberOfLocalItemsOnPage))
            
            var localItems = [WrapData]()
            LocalMediaStorage.default.getInfo(from: nextItemsToSave, completion: { [weak self] info in
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    let assetsInfo = info.filter { $0.isValid }
                    assetsInfo.forEach { element in
                        autoreleasepool {
                            let wrapedItem = WrapData(info: element)
                            localItems.append(wrapedItem)
                        }
                    }
                    DispatchQueue.main.async {
                        self?.uploadOutput?.newLocalItemsReceived(newItems: localItems)
                    }
                    self?.getAllRelatedItemsPageFromPH(assets: Array(assets.dropFirst(nextItemsToSave.count)))
                }
            })
        }
    }
    
    private func getAllRelatedItemsFromDataBase(assets: [PHAsset], itemsCallback: LocalFilesCallBack?) {
        MediaItemOperationsService.shared.allLocalItems(with: assets) { mediaItems in
            var items = mediaItems
            items.sort {
                guard let firstDate = $0.creationDate else {
                    return false
                }
                guard let secondDate = $1.creationDate else {
                    return true
                }
                
                return firstDate > secondDate
            }
            itemsCallback?(items)
        }
    }
    
    func addToUploadOnDemandItems(items: [BaseDataSourceItem]) {
        debugLog("UploadFilesSelectionInteractor addToUploadOnDemandItems")

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
            debugLog("UploadFilesSelectionInteractor addToUploadOnDemandItems UploadService uploadFileList success")

            DispatchQueue.main.async {
                self?.uploadOutput?.addToUploadSuccessed()
            }
        }, fail: { [weak self] errorResponse in
            debugLog("UploadFilesSelectionInteractor addToUploadOnDemandItems UploadService uploadFileList fail")
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
