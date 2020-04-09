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
//            completionBlock?()
            return
        }
     
        SyncServiceManager.shared.backgroundTaskSync { [weak self] _ in
            guard let self = self else {
                
                return
            }
            guard !self.isCancelled else {
                self.semaphore.signal()
                return
            }
            
            self.semaphore.signal()
        }
        
//        semaphore.signal()
        semaphore.wait()
        
    }
}
