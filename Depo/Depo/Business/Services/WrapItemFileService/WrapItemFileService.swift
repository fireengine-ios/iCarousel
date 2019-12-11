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
    
    func createsFolder(createFolder: CreatesFolder, success: FolderOperation?, fail: FailResponse?)
    
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
    
    
    func createsFolder(createFolder: CreatesFolder, success: FolderOperation?, fail: FailResponse?) {
        remoteFileService.createsFolder(createFolder: createFolder, success: success, fail: fail)
    }
    
    func delete(deleteFiles: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        
        let successOperation: FileOperationSucces = {
            MediaItemOperationsService.shared.deleteItems(deleteFiles, completion: {
                success?()
                ItemOperationManager.default.deleteItems(items: deleteFiles)
            })
        }
        
        let failOperation: FailResponse = {  value in
            fail?(value)
        }
        
        let removeItems = remoteItemsUUID(files: deleteFiles)
        if (removeItems.count == 0) {
            successOperation()
            return
        }
        
        let files = TrashFiles(items: removeItems)
        remoteFileService.trash(files: files, success: successOperation, fail: failOperation)
    }
    
    func deleteLocalFiles(deleteFiles: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        let localAssets = assetsForlocalItems(files: deleteFiles)
        if let localAssetsW = localAssets,
            localAssetsW.count > 0 {
            LocalMediaStorage.default.removeAssets(deleteAsset: localAssetsW, success: {
                
                let list: [String] = localAssetsW.map { $0.localIdentifier }
                //                DispatchQueue.main.async {
                MediaItemOperationsService.shared.removeLocalMediaItems(with: list, completion: {})
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
    
    func cancellableUpload(items: [WrapData], toPath: String, success: @escaping FileOperationSucces, fail: @escaping FailResponse, returnedUploadOperations: @escaping ([UploadOperation]?) -> Void) {
        let localFiles = localWrapedData(files: items)
        
        uploadService.uploadFileList(items: localFiles,
                                     uploadType: .fromHomePage,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .MOBILE_UPLOAD,
                                     success: success,
                                     fail: fail,
                                     returnedUploadOperation: returnedUploadOperations)
    }
    
    func syncItemsIfNeeded(_ items: [WrapData], success: @escaping FileOperationSucces, fail: @escaping FailResponse, syncOperations: @escaping ([UploadOperation]?) -> Void) {
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
        
        let uuidsToShare: [String]
        
        /// photo, video, files, folders
        if let sharedItems = sharedFiles as? [WrapData], !sharedItems.isEmpty {
            
            let remoteUUIDs = uuidsOfItemsThatHaveRemoteURL(files: sharedItems)
            let folderUUIDs = remoteFoldersUUIDs(files: sharedItems)
            uuidsToShare = remoteUUIDs + folderUUIDs
            
        /// albums
        } else {
            uuidsToShare = remoteItemsUUID(files: sharedFiles)
        }
        
        guard !uuidsToShare.isEmpty else {
            assertionFailure()
            fail?(ErrorResponse.string(TextConstants.errorServer))
            return
        }
        
        let isAlbum = !sharedFiles.contains(where: { $0.fileType != .photoAlbum })
        let param = SharedServiceParam(filesList: uuidsToShare, isAlbum: isAlbum, sharedType: .link)
        sharedFileService.share(param: param, success: success, fail: fail)
    }
    
    
    // MARK: File detail
    
    func detail(item: WrapData, success: FileOperation?, fail: FailResponse?) {
        remoteFileService.detail(uuids: item.uuid, success: success, fail: fail)
    }
    
    func details(items: [WrapData], success: ListRemoteItems?, fail: FailResponse?) {
        let items = remoteItemsUUID(files: items)
        remoteFileService.details(uuids: items, success: success, fail: fail)
    }
    
    
    // MARK: favourits
    
    func addToFavourite(files: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        metadataFile(files: files, favorites: true, success: success, fail: fail)
    }
    
    func removeFromFavourite(files: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        metadataFile(files: files, favorites: false, success: success, fail: fail)
    }
    
    private func metadataFile(files: [WrapData], favorites: Bool, success: FileOperationSucces?, fail: FailResponse?) {
        
        let items = remoteItemsUUID(files: files)
        let param = MetaDataFile(items: items, addToFavourit: favorites)
        let success_: FileOperationSucces = {
            success?()
            files.forEach {
                $0.favorites = favorites
            }
            if favorites {
                ItemOperationManager.default.addFilesToFavorites(items: files)
            } else {
                ItemOperationManager.default.removeFileFromFavorites(items: files)
            }
            MediaItemOperationsService.shared.updateRemoteItems(remoteItems: files)
        }
        
        remoteFileService.medaDataRequest(param: param, success: success_, fail: fail)
    }
    
    
    private func remoteWrapDataItems(files: [WrapData]) -> [WrapData] {
        return files.filter { !$0.isLocalItem }
    }
    
    private func localWrapedData(files: [WrapData]) -> [WrapData] {
        return files.filter { $0.isLocalItem }
    }
    
    private func assetsForlocalItems(files: [WrapData]) -> [PHAsset]? {
        return files.compactMap { $0.asset }
    }
    
    
    private func remoteItemsUUID(files: [BaseDataSourceItem]) -> [String] {
        return files
            .filter { !$0.isLocalItem }
            .compactMap { $0.uuid }
    }
    
    private func remoteFoldersUUIDs(files: [WrapData]) -> [String] {
        return files
            .filter { $0.isFolder == true }
            .compactMap { $0.uuid }
    }
    
    private func uuidsOfItemsThatHaveRemoteURL(files: [WrapData]) -> [String] {
        return files
            .filter { $0.tmpDownloadUrl != nil }
            .compactMap { $0.uuid }
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
            let isCompleted = items.contains(where: { $0.tmpDownloadUrl != nil || $0.status == .active })
            /// old logic, now we consider its ok, neither if its active or tempo url online
            //!items.contains(where: { $0.status != .active})
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
