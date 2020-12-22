//
//  UploadFilesSelectionUploadFilesSelectionInteractor.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//


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
                options.sortDescriptors = [NSSortDescriptor(key: #keyPath(PHAsset.creationDate), ascending: false)]
                if let album = collectionFetchResult.firstObject {
                    let assetsFetchResult = PHAsset.fetchAssets(in: album, options: options)
                    var assets = [PHAsset]()
                    assetsFetchResult.enumerateObjects({ asset, index, stop in
                        assets.append(asset)
                    })
                    
                    self?.getAllRelatedItemsPageFromPH(assets: assets)
                       
                }
            }
        }
    }
    
    private func getAllRelatedItemsPageFromPH(assets: [PHAsset]) {
        guard !assets.isEmpty else {
            uploadOutput?.newLocalItemsReceived(newItems:[])
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
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
    
    func addToUploadOnDemandItems(items: [BaseDataSourceItem]) {
        debugLog("UploadFilesSelectionInteractor addToUploadOnDemandItems")

        let uploadItems = items as! [WrapData]
        let router = RouterVC()
        let isFavorites = router.isOnFavoritesView()
        let isFromAlbum = router.isRootViewControllerAlbumDetail()
        
        let projectId: String?
        let rooutUUID: String
        let uploadType: UploadType
        if let sharedFolderInfo = router.sharedFolderItem {
            rooutUUID = sharedFolderInfo.uuid
            projectId = sharedFolderInfo.projectId
            uploadType = projectId == SingletonStorage.shared.accountInfo?.projectID ? .upload : .sharedWithMe
        } else {
            rooutUUID = router.getParentUUID()
            projectId = nil
            uploadType = .upload
        }
        
        if isFromAlbum {
            ItemOperationManager.default.startUploadFilesToAlbum(files: uploadItems)
        }
        
        if let errorMessage = verify(items: uploadItems) {
            uploadOutput?.addToUploadFailedWith(errorMessage: errorMessage)
            return
        }
        
        uploadOutput?.addToUploadStarted()
        
        UploadService.default.uploadFileList(items: uploadItems, uploadType: uploadType, uploadStategy: .WithoutConflictControl, uploadTo: .MOBILE_UPLOAD, folder: rooutUUID, isFavorites: isFavorites, isFromAlbum: isFromAlbum, projectId: projectId, success: { [weak self] in

            DispatchQueue.main.async {
                self?.uploadOutput?.addToUploadSuccessed()
            }
        }, fail: { [weak self] errorResponse in
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
