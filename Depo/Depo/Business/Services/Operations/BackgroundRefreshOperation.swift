//
//  BackgroundRefreshOperation.swift
//  Depo
//
//  Created by Alex Developer on 09.04.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class BackgroundRefreshOperation: Operation {
    
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
    
    ///For now we need to check only last one
    private func rangeApiUpdate() {
        debugLog("BG! range API update")
        var quickScrollService = QuickScrollService()
        
        let rangeApiTopInfo = RangeAPIInfo(date: Date.distantFuture, id: nil)
        let rangeApiBottomInfo = RangeAPIInfo(date: Date.distantPast, id: nil)
        
        quickScrollService.requestListOfDateRange(startDate: rangeApiTopInfo.date, endDate: rangeApiBottomInfo.date, startID: rangeApiTopInfo.id, endID: rangeApiBottomInfo.id, category: .photosAndVideos, pageSize: 1) { response in
            
            switch response {
            case .success(let itemsList):
                debugLog("BG! range API list recieved")
                guard let item = itemsList.files.first else {
                    debugLog("BG! ERROR range API list no items")
                    self.semaphore.signal()
                    return
                }
                MediaItemOperationsService.shared.updateRemoteItems(remoteItems: itemsList.files, fileType: item.fileType, topInfo: rangeApiTopInfo, bottomInfo: rangeApiBottomInfo, completion: {
                    debugPrint("BG! appended and updated")
                    self.semaphore.signal()
                })
                
            case .failed(let error):
                debugLog("BG! range API list failed \(error.description)")
                self.semaphore.signal()
                break
            }
            
        }
        
    }
    
}

extension BackgroundRefreshOperation: CacheManagerDelegate {
    func didCompleteCacheActualization() {
        CacheManager.shared.delegates.remove(self)
        debugLog("BG! finished actualziing delegate cache")
        rangeApiUpdate()
    }
}
