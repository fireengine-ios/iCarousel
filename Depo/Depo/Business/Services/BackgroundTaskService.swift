//
//  BackgroundTaskService.swift
//  Depo
//
//  Created by Konstantin on 4/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation



final class BackgroundTaskService {
    
    static let shared = BackgroundTaskService()
    
    private var backgroundTaskId = UIBackgroundTaskInvalid
    
    
    func beginBackgroundTask() {
        guard backgroundTaskId == UIBackgroundTaskInvalid else {
            return
        }
        
        self.backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: UUID().uuidString, expirationHandler: { [weak self] in
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
