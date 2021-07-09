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
    
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    private (set) var appWasSuspended = false
    
    func beginBackgroundTask() {
        appWasSuspended = false
        
        guard
            backgroundTaskId == .invalid
        else {
            return
        }
        
        self.backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: UUID().uuidString, expirationHandler: { [weak self] in
            debugLog("App will be suspended")
            self?.expirationDelegates.invoke(invocation: { delegate in
                delegate.backgroundTaskWillExpire()
            })
            self?.appWasSuspended = true
            debugLog("App is suspended")
            self?.endBackgroundTask()
        })

        debugLog("beginBackgroundTask \(self.backgroundTaskId)")
    }
    
    private func endBackgroundTask() {
        if self.backgroundTaskId != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
            debugLog("endBackgroundTask \(backgroundTaskId)")
            backgroundTaskId = .invalid
        }
    }
}
