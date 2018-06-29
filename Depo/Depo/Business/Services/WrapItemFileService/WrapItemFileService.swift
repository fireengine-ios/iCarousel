//
//  WrapItemFileSetvice.swift
//  Depo
//
//  Created by Alexander Gurin on 8/7/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import Photos

typealias FileOperationSucces = () -> Void

protocol  WrapItemFileOperations {
    
    func createsFolder(createFolder: CreatesFolder, success: FileOperation?, fail: FailResponse?)
    
    func delete(deleteFiles: [WrapData], success: FileOperationSucces?, fail: FailResponse?)
    
    func move(items: [WrapData], toPath: String, success: FileOperationSucces?, fail: FailResponse?)
    
    func copy(items: [WrapData], toPath: String, success: FileOperationSucces?, fail: FailResponse?)
    
    func upload(items: [WrapData], toPath: String, success: @escaping FileOperationSucces, fail: @escaping FailResponse)
    
    func download(items: [WrapData], toPath: String, success: FileOperationSucces?, fail: FailResponse?)
    
    func share(sharedFiles: [BaseDataSourceItem], success: SuccessShared?, fail: FailResponse?)
    
    
    // MARK: favourits
    
    func addToFavourite(files: [WrapData], success: FileOperationSucces?, fail: FailResponse?)
    
    func removeFromFavourite(files: [WrapData], success: FileOperationSucces?, fail: FailResponse?)
    
}

class WrapItemFileService: WrapItemFileOperations {
    
    let remoteFileService = FileService.shared
    
    let sharedFileService = SharedService()
    
    let uploadService = UploadService.default
    
    
    func createsFolder(createFolder: CreatesFolder, success: FileOperation?, fail: FailResponse?) {
        remoteFileService.createsFolder(createFolder: createFolder, success: success, fail: fail)
    }
    
    func delete(deleteFiles: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        
        let successOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.deleteItems(items: deleteFiles)
        }
        
        let failOperation: FailResponse = {  value in
            fail?(value)
        }
        
        let removeItems = remoteItemsUUID(files: deleteFiles)
        if (removeItems.count == 0) {
            successOperation()
            return
        }
        
        let param = DeleteFiles(items: removeItems)
        remoteFileService.delete(deleteFiles: param,
                                 success: successOperation,
                                 fail: failOperation)
        
    }
    
    func deleteLocalFiles(deleteFiles: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        let localAssets = assetsForlocalItems(files: deleteFiles)
        if let localAssetsW = localAssets,
            localAssetsW.count > 0 {
            LocalMediaStorage.default.removeAssets(deleteAsset: localAssetsW, success: {
                
                let list: [String] = localAssetsW.map { $0.localIdentifier }
                //                DispatchQueue.main.async {
                CoreDataStack.default.removeLocalMediaItems(with: list, completion: {})
                ItemOperationManager.default.deleteItems(items: deleteFiles)
                //                }
                success?()
            }, fail: fail)
            
        } else {
            success?()
        }
    }
    
    func move(items: [WrapData], toPath: String, success: FileOperationSucces?, fail: FailResponse?) {
        
        let removeItems = remoteItemsUUID(files: items)
        let param = MoveFiles(items: removeItems, path: toPath)
        remoteFileService.move(moveFiles: param, success: success, fail: fail)
    }
    
    func copy(items: [WrapData], toPath: String, success: FileOperationSucces?, fail: FailResponse?) {
        
        let removeItems = remoteItemsUUID(files: items)
        let param = CopyFiles(items: removeItems, path: toPath)
        remoteFileService.copy(copyparam: param, success: success, fail: fail)
    }
    
    func upload(items: [WrapData], toPath: String, success: @escaping FileOperationSucces, fail: @escaping FailResponse) {
        let localFiles = localWrapedData(files: items)
        
        uploadService.uploadFileList(items: localFiles,
                                     uploadType: .fromHomePage,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .MOBILE_UPLOAD,
                                     success: success,
                                     fail: fail, returnedUploadOperation: { _ in})
    }
    
    func syncItemsIfNeeded(_ items: [WrapData], success: @escaping FileOperationSucces, fail: @escaping FailResponse, syncOperations: @escaping ([UploadOperations]?) -> Void) {
        let localFiles = localWrapedData(files: items)
        guard localFiles.count > 0 else {
            success()
            return
        }
        
        
        uploadService.uploadFileList(items: localFiles,
                                     uploadType: .syncToUse,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .MOBILE_UPLOAD,
                                     success: {
                                        debugLog("SyncToUse - Waiting for item details")
                                        WrapItemFileService.waitItemsDetails(for: items,
                                                                             maxAttempts: NumericConstants.maxDetailsLoadingAttempts,
                                                                             success: success,
                                                                             fail: fail)
        },
                                     fail: { error in
                                        if error.description == TextConstants.canceledOperationTextError {
                                            return
                                        }
                                        fail(error)
        }, returnedUploadOperation: { operations in
            syncOperations(operations)
        })
    }
    
    func download(items: [WrapData], toPath: String, success: FileOperationSucces?, fail: FailResponse?) {
        let downloadItems = remoteWrapDataItems(files: items)
        
        remoteFileService.download(items: downloadItems, success: success, fail: fail)
    }
    
    func download(itemsByAlbums: [AlbumItem: [Item]], success: FileOperationSucces?, fail: FailResponse?) {
        let group = DispatchGroup()
        
        for (album, items) in itemsByAlbums {
            let downloadItems = remoteWrapDataItems(files: items)
            guard downloadItems.count > 0 else { continue }
            group.enter()
            remoteFileService.download(items: downloadItems, album: album, success: {
                group.leave()
            }, fail: { error in
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            success?()
        }
    }
    
    func share(sharedFiles: [BaseDataSourceItem], success: SuccessShared?, fail: FailResponse?) {
        let items = remoteItemsUUID(files: sharedFiles)
        let isAlbum = !sharedFiles.contains(where: { $0.fileType != .photoAlbum })
        let param = SharedServiceParam(filesList: items, isAlbum: isAlbum, sharedType: .link)
        sharedFileService.share(param: param, success: success, fail: fail)
    }
    
    
    // MARK: File detail
    
    func detail(item: WrapData, success: FileOperation?, fail: FailResponse?) {
        remoteFileService.detail(uuids: item.uuid, success: success, fail: fail)
    }
    
    func details(items: [WrapData], success: ListRemoveItems?, fail: FailResponse?) {
        let items = remoteItemsUUID(files: items)
        remoteFileService.details(uuids: items, success: success, fail: fail)
    }
    
    
    // MARK: favourits
    
    func addToFavourite(files: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        metadataFile(files: files, favouritse: true, success: success, fail: fail)
    }
    
    func removeFromFavourite(files: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        metadataFile(files: files, favouritse: false, success: success, fail: fail)
    }
    
    private func metadataFile(files: [WrapData], favouritse: Bool, success: FileOperationSucces?, fail: FailResponse?) {
        
        let items = remoteItemsUUID(files: files)
        let param = MetaDataFile(items: items, addToFavourit: favouritse)
        let success_: FileOperationSucces = {
            success?()
            files.forEach {
                $0.coreDataObject?.favoritesValue = favouritse
            }
            if (favouritse) {
                ItemOperationManager.default.addFilesToFavorites(items: files)
            } else {
                ItemOperationManager.default.removeFileFromFavorites(items: files)
            }
        }
        
        remoteFileService.medaDataRequest(param: param, success: success_, fail: fail)
    }
    
    
    private func remoteWrapDataItems(files: [WrapData]) -> [WrapData] {
        let items = files.filter { !$0.isLocalItem }
        return items
    }
    
    private func localWrapedData(files: [WrapData]) -> [WrapData] {
        let items = files.filter { $0.isLocalItem }
        return items
    }
    
    private func assetsForlocalItems(files: [WrapData]) -> [PHAsset]? {
        let assets = files.flatMap { $0.asset }
        return assets
    }
    
    
    private func remoteItemsUUID(files: [BaseDataSourceItem]) -> [String] {
        let items: [String] = files.filter { !$0.isLocalItem }
            .flatMap { $0.uuid }
        return items
    }
    
    static private func waitItemsDetails(for items: [WrapData], currentAttempt: Int = 0, maxAttempts: Int, success: FileOperationSucces?, fail: FailResponse?) {
        let fileService = FileService.shared
        fileService.details(uuids: items.map({ $0.uuid }), success: { updatedItems in
            for item in updatedItems {
                if let itemToUpdate = items.filter({ $0.uuid == item.uuid }).first {
                    itemToUpdate.metaData = item.metaData
                    itemToUpdate.tmpDownloadUrl = item.tmpDownloadUrl
                    itemToUpdate.status = item.status
                }
            }
            let isCompleted = !items.contains(where: { $0.status != .active })
            if isCompleted {
                success?()
            } else if currentAttempt < maxAttempts {
                sleep(NumericConstants.detailsLoadingTimeAwait)
                debugLog("SyncToUse - Item details. Attempt number \(currentAttempt)")
                waitItemsDetails(for: items,
                                 currentAttempt: currentAttempt + 1,
                                 maxAttempts: maxAttempts,
                                 success: success,
                                 fail: fail)
            } else {
                debugLog("SyncToUse - Item details. Number of attempts is exhausted")
                fail?(ErrorResponse.string(TextConstants.errorServer))
            }
        }, fail: fail)
    }
}
