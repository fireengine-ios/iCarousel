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
            DispatchQueue.main.async {
                print("BACKGROUND: \(UIApplication.shared.backgroundTimeRemaining)")
                //1.79769313486232E+308 means infinite time
            }
            return
        }
        
        self.backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: UUID().uuidString, expirationHandler: { [weak self] in
            self?.endBackgroundTask()
        })
        
        DispatchQueue.main.async {
            print("BACKGROUND: \(UIApplication.shared.backgroundTimeRemaining)")
            //1.79769313486232E+308 means infinite time
        }
        print("BACKGROUND: Task \(backgroundTaskId) has been added")
    }
    
    private func endBackgroundTask() {
        if self.backgroundTaskId != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
            backgroundTaskId = UIBackgroundTaskInvalid
            print("BACKGROUND: Task \(backgroundTaskId) has been ended")
        }
    }
}
