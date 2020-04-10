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
        CacheManager.shared.actualizeCache()
        semaphore.wait()
    }
}

extension BackgroundRefreshOperation: CacheManagerDelegate {
    func didCompleteCacheActualization() {
        CacheManager.shared.delegates.remove(self)
        debugLog("BG! finished actualziing delegate cache")
        self.semaphore.signal()
    }
}
