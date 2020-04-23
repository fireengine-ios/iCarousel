//
//  BackgroundRefreshOperation.swift
//  Depo
//
//  Created by Alex Developer on 09.04.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class BackgroundSyncOperation: Operation {
    
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
        
        guard !isCancelled else {
            debugLog("BG! task cancelled after actualizeCache")
            completionBlock?() //force call, since we didnt recieve callback
            return
        }
        
        debugLog("BG! about to backgroundTaskSync")
        SyncServiceManager.shared.backgroundTaskSync { [weak self] successful in
            debugLog("BG! backgroundTaskSync callback \(successful)")
            guard let self = self else {
                debugLog("BG! task cancelled")
                return
            }
            if !successful {
                debugLog("BG! self cancellation")
                self.cancel()
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
}

extension BackgroundSyncOperation: CacheManagerDelegate {
    func didCompleteCacheActualization() {
        CacheManager.shared.delegates.remove(self)
        debugLog("BG! finished actualziing delegate cache")
        self.semaphore.signal()
    }
}
