//
//  BackgroundSynkService.swift
//  Depo
//
//  Created by Maxim Soldatov on 2/10/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import BackgroundTasks

@available(iOS 13.0, *)
extension BackgroundSynkService {
    static let backgroundSynkService = BackgroundSynkService()
}

@available(iOS 13.0, *)
final class BackgroundSynkService {
    
    private enum TaskIdentifiers {
        static let backgroundSync = "background_sync"
    }
    
    //MARK: Service
    private lazy var accountService: AccountServicePrl = AccountService()
    private lazy var storageVars: StorageVars = factory.resolve()
    
    
    func registerLaunchHandlers() {
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: TaskIdentifiers.backgroundSync, using: DispatchQueue.global()) { task in
            
            guard let task = task as? BGProcessingTask else {
                return
            }
            
            self.handleBackgroundSyncTask(task: task)
        }
    }
        
    func scheduleBackgroundSync() {
        
        let request = BGProcessingTaskRequest(identifier: TaskIdentifiers.backgroundSync)
        
        // Fetch no earlier than 15 sec from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = true
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
        
    }
    
    private func handleBackgroundSyncTask(task: BGProcessingTask) {

        guard LocalMediaStorage.default.photoLibraryIsAvailible(), storageVars.autoSyncSet else {
            return
        }
        
        SyncServiceManager.shared.backgroundTaskSync { isLast in
            task.setTaskCompleted(success: isLast)
        }
        
        task.expirationHandler = {
            SyncServiceManager.shared.stopSync()
        }
        scheduleBackgroundSync()
    }
    
}
