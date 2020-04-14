//
//  BackgroundTaskService.swift
//  Depo
//
//  Created by Konstantin on 4/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol BackgroundTaskServiceDelegate: class {
    func backgroundTaskWillExpire()
}


final class BackgroundTaskService {
    
    static let shared = BackgroundTaskService()
    
    var expirationDelegates = MulticastDelegate<BackgroundTaskServiceDelegate>()
    
    private var backgroundTaskId = UIBackgroundTaskInvalid
    private (set) var appWasSuspended = false
    
    func beginBackgroundTask() {
        appWasSuspended = false
        
        guard
            backgroundTaskId == UIBackgroundTaskInvalid,
            Device.operationSystemVersionLessThen(13)
        else {
            debugLog("beginBackgroundTask iOS more then or equal to 13")
            return
        }
        
        self.backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: UUID().uuidString, expirationHandler: { [weak self] in
            self?.appWasSuspended = true
            self?.expirationDelegates.invoke(invocation: { delegate in
                delegate.backgroundTaskWillExpire()
            })
            self?.endBackgroundTask()
        })

        debugLog("beginBackgroundTask \(self.backgroundTaskId)")
    }
    
    private func endBackgroundTask() {
        if self.backgroundTaskId != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
            debugLog("endBackgroundTask \(backgroundTaskId)")
            backgroundTaskId = UIBackgroundTaskInvalid
        }
    }
}
