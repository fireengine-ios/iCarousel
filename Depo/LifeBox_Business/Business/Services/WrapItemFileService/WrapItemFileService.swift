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
    private let hiddenService = HiddenService()
    private lazy var privateShareApiService = PrivateShareApiServiceImpl()
    
    
    func createsFolder(createFolder: CreatesFolder, success: FolderOperation?, fail: FailResponse?) {
        remoteFileService.createsFolder(createFolder: createFolder, success: success, fail: fail)
    }
    
    func delete(deleteFiles: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        
        let successOperation: FileOperationSucces = {
            ItemOperationManager.default.deleteItems(items: deleteFiles)
            success?()
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
    
    func moveToTrash(files: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        
        let successOperation: FileOperationSucces = {
            ItemOperationManager.default.didMoveToTrashItems(files)
            success?()
        }
        
        let failOperation: FailResponse = {  value in
            fail?(value)
        }
        
        let removeItems = files
            .filter { !$0.isLocalItem}
        
        if removeItems.isEmpty {
            successOperation()
            return
        }
        
        moveToTrashShared(files: removeItems, success: successOperation, fail: failOperation)
    }
    
    func deleteLocalFiles(deleteFiles: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        let localAssets = assetsForlocalItems(files: deleteFiles)
        if let localAssetsW = localAssets,
            localAssetsW.count > 0 {
            LocalMediaStorage.default.removeAssets(deleteAsset: localAssetsW, success: {
                
                let list: [String] = localAssetsW.map { $0.localIdentifier }
                ItemOperationManager.default.deleteItems(items: deleteFiles)
                success?()
            }, fail: fail)
            
        } else {
            success?()
        }
    }
    
    func endSharing(file: WrapData, success: FileOperationSucces?, fail: FailResponse?) {
        privateShareApiService.endShare(projectId: file.accountUuid, uuid: file.uuid) { response in
            switch response {
                case .success(()):
                    success?()
                    
                case .failed(let error):
                    fail?(ErrorResponse.error(error))
            }
        }
    }
    
    func leaveSharing(file: WrapData, success: FileOperationSucces?, fail: FailResponse?) {
        guard let subjectId = SingletonStorage.shared.accountInfo?.uuid else {
            fail?(ErrorResponse.string("don't have projectId or subjectId"))
            return
        }
        
        privateShareApiService.leaveShare(projectId: file.accountUuid, uuid: file.uuid, subjectId: subjectId) { response in
            switch response {
                case .success(()):
                    success?()
                    
                case .failed(let error):
                    fail?(ErrorResponse.error(error))
            }
        }
    }
    
    func moveToTrashShared(files: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        let filesToRemove = files.compactMap { ($0.accountUuid, $0.uuid) }
        privateShareApiService.moveToTrash(files: filesToRemove) { response in
            switch response {
                case .success(()):
                    success?()
                    
                case .failed(let error):
                    fail?(ErrorResponse.error(error))
            }
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
                                     uploadType: .upload,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .ROOT,
                                     success: success,
                                     fail: fail, returnedUploadOperation: { _ in})
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
                                     uploadTo: .ROOT,
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
    
    func downloadDocuments(items: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        let downloadItems = remoteWrapDataItems(files: items)
        
        let itemsWithoutUrl = items.filter { $0.tmpDownloadUrl == nil || !$0.isOwner }
        
        createDownloadUrls(for: itemsWithoutUrl) { [weak self] in
            self?.remoteFileService.downloadDocument(items: downloadItems, success: success, fail: fail)
        }
    }
    
    func download(items: [WrapData], toPath: String, success: FileOperationSucces?, fail: FailResponse?) {
        let downloadItems = remoteWrapDataItems(files: items)
        
        let itemsWithoutUrl = items.filter { $0.tmpDownloadUrl == nil || !$0.isOwner }
        
        createDownloadUrls(for: itemsWithoutUrl) { [weak self] in
            self?.remoteFileService.download(items: downloadItems, success: success, fail: fail)
        }
    }
    
    func createDownloadUrls(for items: [WrapData], completion: @escaping VoidHandler) {
        let group = DispatchGroup()
        
        items.forEach { item in
            group.enter()
            
            privateShareApiService.createDownloadUrl(projectId: item.accountUuid, uuid: item.uuid) { response in
                if case let ResponseResult.success(urlToDownload) = response {
                    item.tmpDownloadUrl = urlToDownload.url
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main, execute: completion)
    }
    
    func share(sharedFiles: [BaseDataSourceItem], success: SuccessShared?, fail: FailResponse?) {
        
        let uuidsToShare: [String]
        
        /// photo, video, files, folders
        if let sharedItems = sharedFiles as? [WrapData], !sharedItems.isEmpty {

            let downloadUrlUuids = uuidsOfItemsThatHaveRemoteURL(files: sharedItems)
            let folderUuids = remoteFoldersUUIDs(files: sharedItems)
            let remoteUuids = remoteItemsUUID(files: sharedItems)
            let combined = Set(downloadUrlUuids + folderUuids + remoteUuids)
            uuidsToShare = Array(combined)
            
        /// albums
        } else {
            uuidsToShare = remoteItemsUUID(files: sharedFiles)
        }
        
        guard !uuidsToShare.isEmpty else {
            assertionFailure()
            fail?(ErrorResponse.string(TextConstants.errorServer))
            return
        }
        
        let param = SharedServiceParam(filesList: uuidsToShare, isAlbum: false, sharedType: .link)
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
            let isCompleted = items.contains(where: { $0.tmpDownloadUrl != nil || $0.status.isTranscoded })
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

//MARK: - Trash
extension WrapItemFileService {
    
    //MARK: - Delete Items
    
    func delete(items: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            ItemOperationManager.default.deleteItems(items: items)
            success?()
        }
        
        let remoteItems = items.filter { !$0.isLocalItem }
        guard !remoteItems.isEmpty else {
            wrappedSuccessOperation()
            return
        }
        
        hiddenService.delete(items: remoteItems) { response in
            switch response {
            case .success(()):
                wrappedSuccessOperation()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    //MARK: - Delete All From Trash Bin
    
    func deletAllFromTrashBin(success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            ItemOperationManager.default.didEmptyTrashBin()
            success?()
        }
        
        hiddenService.deleteAllFromTrashBin { response in
            switch response {
            case .success(_):
                wrappedSuccessOperation()
                success?()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
}


//MARK: - Recover

extension WrapItemFileService {
    
    //MARK: [WrapData]
    
    func putBack(items: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            ItemOperationManager.default.putBackFromTrashItems(items)
            success?()
        }
        
        recover(items: items, success: wrappedSuccessOperation, fail: fail)
    }
    
    private func recover(items: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        let remoteItems = items.filter { !$0.isLocalItem }
        guard !remoteItems.isEmpty else {
            success?()
            return
        }
        
        hiddenService.recoverItems(remoteItems) { response in
            switch response {
            case .success(()):
                success?()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
}
