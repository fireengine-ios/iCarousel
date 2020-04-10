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
                self.semaphore.signal()
                self.completionBlock?() //force call, since we didnt recieve callback
                return
            }
            
            self.semaphore.signal()
        }

        semaphore.wait()
        
    }
}
