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
        
        let param = DeleteFiles(items: removeItems)
        remoteFileService.delete(deleteFiles: param,
                                 success: successOperation,
                                 fail: failOperation)
    }
    
    func moveToTrash(files: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        
        let successOperation: FileOperationSucces = {
            //TODO: - Need change status to TRASHED
            MediaItemOperationsService.shared.deleteItems(files, completion: {
                success?()
                //TODO: - Need to replace deleteItems with moveToTrash for delegates
                ItemOperationManager.default.deleteItems(items: files)
                ItemOperationManager.default.didMoveToTrashItems(files)
            })
        }
        
        let failOperation: FailResponse = {  value in
            fail?(value)
        }
        
        let removeItems = remoteItemsUUID(files: files)
        if removeItems.isEmpty {
            successOperation()
            return
        }
        
        let files = MoveToTrashFiles(items: removeItems)
        remoteFileService.moveToTrash(files: files, success: successOperation, fail: failOperation)
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
    
    func hide(items: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            MediaItemOperationsService.shared.hide(items, completion: {
                success?()
                ItemOperationManager.default.didHideItems(items)
            })
        }
        
        let remoteItems = items.filter { !$0.isLocalItem }
        guard !remoteItems.isEmpty else {
            wrappedSuccessOperation()
            return
        }
        
        hiddenService.hideItems(remoteItems) { response in
            switch response {
            case .success(()):
                wrappedSuccessOperation()
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
            MediaItemOperationsService.shared.deleteItems(items, completion: {
                success?()
                ItemOperationManager.default.deleteItems(items: items)
            })
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
    
    func deleteAlbums(_ albums: [AlbumItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.albumsDeleted(albums: albums)
        }
        
        let deletingAlbums = albums.filter { $0.readOnly == false }
        guard !deletingAlbums.isEmpty else {
            wrappedSuccessOperation()
            return
        }
        
        hiddenService.deleteAlbums(deletingAlbums) { response in
            switch response {
            case .success(()):
                wrappedSuccessOperation()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    
    //MARK: - Smart Albums Trash
    
    @discardableResult
    func moveToTrashPeople(items: [PeopleItem], success: FileOperationSucces?, fail: FailResponse?) -> URLSessionTask? {
        debugLog("moveToTrashPeopleItems")

        return hiddenService.moveToTrashPeople(items: items){ response in
            switch response {
            case .success(()):
                success?()
                ItemOperationManager.default.didMoveToTrashPeople(items: items)
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    @discardableResult
    func moveToTrashPlaces(items: [PlacesItem], success: FileOperationSucces?, fail: FailResponse?) -> URLSessionTask? {
        debugLog("moveToTrashPlacesItems")
        
        return hiddenService.moveToTrashPlaces(items: items){ response in
            switch response {
            case .success(()):
                success?()
                ItemOperationManager.default.didMoveToTrashPlaces(items: items)
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    @discardableResult
    func moveToTrashThings(items: [ThingsItem], success: FileOperationSucces?, fail: FailResponse?) -> URLSessionTask? {
        debugLog("moveToTrashThingsItems")
        return hiddenService.moveToTrashThings(items: items) { response in
            switch response {
            case .success(()):
                success?()
                ItemOperationManager.default.didMoveToTrashThings(items: items)
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
}


//MARK: - Recover

extension WrapItemFileService {
    
    //MARK: [WrapData]
    func unhide(items: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            MediaItemOperationsService.shared.recover(items, completion: {
                success?()
                ItemOperationManager.default.didUnhideItems(items)
            })
        }
        
        recover(items: items, success: wrappedSuccessOperation, fail: fail)
    }
    
    func putBack(items: [WrapData], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            MediaItemOperationsService.shared.recover(items, completion: {
                success?()
                ItemOperationManager.default.putBackFromTrashItems(items)
            })
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
    
    //MARK: [AlbumItem]
    func unhideAlbums(_ albums: [AlbumItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.didUnhideAlbums(albums)
        }
        
        recoverAlbums(albums, success: wrappedSuccessOperation, fail: fail)
    }
    
    func putBackAlbums(_ albums: [AlbumItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.putBackFromTrashAlbums(albums)
        }
        
        recoverAlbums(albums, success: wrappedSuccessOperation, fail: fail)
    }
    
    private func recoverAlbums(_ albums: [AlbumItem], success: FileOperationSucces?, fail: FailResponse?) {
        guard !albums.isEmpty else {
            success?()
            return
        }
        
        hiddenService.recoverAlbums(albums) { response in
            switch response {
            case .success(()):
                success?()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
}


//MARK: - FIR
extension WrapItemFileService {
    
    //MARK: People
    
    func unhidePeople(items: [PeopleItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.didUnhidePeople(items: items)
        }
        
        hiddenService.unhidePeople(items: items) { result in
            switch result {
            case .success(_):
                wrappedSuccessOperation()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    func putBackPeople(items: [PeopleItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.putBackFromTrashPeople(items: items)
        }
        
        hiddenService.putBackPeople(items: items) { result in
            switch result {
            case .success(_):
                wrappedSuccessOperation()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    func deletePeople(items: [PeopleItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.deleteItems(items: items)
        }
        
        hiddenService.deletePeople(items: items) { result in
            switch result {
            case .success(_):
                wrappedSuccessOperation()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    
    //MARK: Places
    
    func unhidePlaces(items: [PlacesItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.didUnhidePlaces(items: items)
        }
        
        hiddenService.unhidePlaces(items: items) { result in
            switch result {
            case .success(_):
                wrappedSuccessOperation()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    func putBackPlaces(items: [PlacesItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.putBackFromTrashPlaces(items: items)
        }
        
        hiddenService.putBackPlaces(items: items) { result in
            switch result {
            case .success(_):
                wrappedSuccessOperation()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    func deletePlaces(items: [PlacesItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.deleteItems(items: items)
        }
        
        hiddenService.deletePlaces(items: items) { result in
            switch result {
            case .success(_):
                wrappedSuccessOperation()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    //MARK: Things
    
    func unhideThings(items: [ThingsItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.didUnhideThings(items: items)
        }
        
        hiddenService.unhideThings(items: items) { result in
            switch result {
            case .success(_):
                wrappedSuccessOperation()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    func putBackThings(items: [ThingsItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.putBackFromTrashThings(items: items)
        }
        
        hiddenService.putBackThings(items: items) { result in
            switch result {
            case .success(_):
                wrappedSuccessOperation()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
    
    func deleteThings(items: [ThingsItem], success: FileOperationSucces?, fail: FailResponse?) {
        let wrappedSuccessOperation: FileOperationSucces = {
            success?()
            ItemOperationManager.default.deleteItems(items: items)
        }
        
        hiddenService.deleteThings(items: items) { result in
            switch result {
            case .success(_):
                wrappedSuccessOperation()
            case .failed(let error):
                fail?(ErrorResponse.error(error))
            }
        }
    }
}
