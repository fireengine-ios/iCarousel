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
//    override func cancel() {
//            super.cancel()
//
//            DispatchQueue.main.async {
//                self.task?.cancel()
//                self.task = nil
//            }
//    //        semaphore.signal()
//        }
        
    override func main() {
        guard !isCancelled else {
            debugLog("BG! task cancelled")
//            completionBlock?()
            return
        }
        debugLog("BG! about to backgroundTaskSync")
        SyncServiceManager.shared.backgroundTaskSync { [weak self] _ in
            debugLog("BG! backgroundTaskSync callback")
            guard let self = self else {
                debugLog("BG! task cancelled")
                return
            }
            guard !self.isCancelled else {
                debugLog("BG! task cancelled")
                self.semaphore.signal()
                return
            }
            
            self.semaphore.signal()
        }
        
//        semaphore.signal()
        semaphore.wait()
        
    }
}
