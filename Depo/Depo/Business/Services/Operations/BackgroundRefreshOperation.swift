//
//  BackgroundRefreshOperation.swift
//  Depo
//
//  Created by Alex Developer on 09.04.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class BackgroundRefreshOperation: Operation {
    
    private let storageVars: StorageVars = factory.resolve()
    private let semaphore = DispatchSemaphore(value: 0)

    override func main() {
        guard !isCancelled else {
            debugLog("BG! task cancelled at the beggining")
            completionBlock?() //force call, since we didnt recieve callback
            return
        }
        
        debugLog("BG! starting to actualize cache")
        
        actualizeCache()
        debugLog("BG! finished actualizing cache")
        
        debugLog("BG! about to backgroundTaskSync")
        SyncServiceManager.shared.backgroundTaskSync { [weak self] successful in
            debugLog("BG! backgroundTaskSync callback \(successful)")
            if !successful {
                debugLog("BG! self cancellation")
                self?.cancel()
            }
            guard let self = self else {
                debugLog("BG! task cancelled")
                return
            }
            guard !self.isCancelled else {
                debugLog("BG! task cancelled also completion")
                CacheManager.shared.delegates.remove(self)
                self.semaphore.signal()
                self.completionBlock?() //force call, since we didnt recieve callback
                return
            }
            CacheManager.shared.delegates.remove(self)
            self.semaphore.signal()
        }

        semaphore.wait()
        
    }
    
    private func actualizeCache() {
        CacheManager.shared.delegates.add(self)
        if !CacheManager.shared.isProcessing {
            CacheManager.shared.actualizeCache()
        }
        semaphore.wait()
    }
    
//    ///For now we need to check only last one
//    private func rangeApiUpdate() {
//        debugLog("BG! range API update")
//        var quickScrollService = QuickScrollService()
//        
//        let rangeApiTopInfo = RangeAPIInfo(date: Date.distantFuture, id: nil)
//        let rangeApiBottomInfo = RangeAPIInfo(date: Date.distantPast, id: nil)
//        
//        quickScrollService.requestListOfDateRange(startDate: rangeApiTopInfo.date, endDate: rangeApiBottomInfo.date, startID: rangeApiTopInfo.id, endID: rangeApiBottomInfo.id, category: .photosAndVideos, pageSize: 1) { response in
//            
//            switch response {
//            case .success(let itemsList):
//                debugLog("BG! range API list recieved")
//                guard let item = itemsList.files.first else {
//                    debugLog("BG! ERROR range API list no items")
//                    self.semaphore.signal()
//                    return
//                }
//                MediaItemOperationsService.shared.updateRemoteItems(remoteItems: itemsList.files, fileType: item.fileType, topInfo: rangeApiTopInfo, bottomInfo: rangeApiBottomInfo, completion: {
//                    debugPrint("BG! appended and updated")
//                    self.semaphore.signal()
//                })
//                
//            case .failed(let error):
//                debugLog("BG! range API list failed \(error.description)")
//                self.semaphore.signal()
//                break
//            }
//            
//        }
//        
//    }
    
    private func checkLatestUnsavedFile() {
        debugLog("BG! checkLatestUnsavedFile")
        guard let latestUnsavedUUID = storageVars.lastUnsavedFileUUID else {
            debugLog("BG! no unsaved items found")
            self.semaphore.signal()
            return
        }
        
        let remoteFileService = FileService.shared
        remoteFileService.details(uuids: [latestUnsavedUUID], success: { [weak self] items in
            guard let remoteItem = items.first else {
                debugLog("BG! no item with this UUID \(items.count)")
                self?.semaphore.signal()
                return
            }
            debugLog("BG! got detail info for last UNSAVED to DB \(remoteItem.uuid) AND name \(remoteItem.name)")
            
            let trimmedLocalID = remoteItem.getTrimmedLocalID()
            
            MediaItemOperationsService.shared.mediaItemByLocalID(trimmedLocalIDS: [trimmedLocalID]) { [weak self] localItems in
                guard let firstLocal = localItems.first else {
                    debugLog("BG! ERROR: Failed to find related locals with this  ID")
                    self?.semaphore.signal()
                    return
                }
                debugLog("BG! found related local to unsaved remote")
                
                let localWrapData = WrapData(mediaItem: firstLocal)
                localWrapData.syncStatus = .synced
                localWrapData.setSyncStatusesAsSyncedForCurrentUser()
                
                MediaItemOperationsService.shared.updateLocalItemSyncStatus(item: localWrapData, newRemote: remoteItem) { [weak self] in
                    debugLog("BG! TEST: SYNC stasus updated last unsaved UPDATED uuid \(self?.storageVars.lastUnsavedFileUUID) AND name \(remoteItem.name)")
                    self?.storageVars.lastUnsavedFileUUID = nil
                    self?.semaphore.signal()
                }
            }
        }, fail: { [weak self] error in
            debugLog("BG! ERROR faild to get item details")
            self?.semaphore.signal()
        })
        
        
    }
    
}

extension BackgroundRefreshOperation: CacheManagerDelegate {
    func didCompleteCacheActualization() {
        CacheManager.shared.delegates.remove(self)
        debugLog("BG! finished actualziing delegate cache")
        checkLatestUnsavedFile()
    }
}
