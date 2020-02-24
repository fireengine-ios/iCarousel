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
        static let backgroundProcessing = "background_processing"
        static let backgroundRefresh = "background_refresh"
    }
    
    //MARK: Service
    private lazy var accountService: AccountServicePrl = AccountService()
    private lazy var storageVars: StorageVars = factory.resolve()
    
    
    func registerLaunchHandlers() {
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: TaskIdentifiers.backgroundProcessing, using: DispatchQueue.global()) { task in
            
            guard let task = task as? BGProcessingTask else {
                return
            }
           self.handleProcessingSyncTask(task: task)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: TaskIdentifiers.backgroundRefresh, using: DispatchQueue.global()) { task in
            
            guard let task = task as? BGAppRefreshTask else {
                return
            }
            self.handleRefreshSyncTask(task: task)
        }

    }
    
    func scheduleProcessingSync() {
        
        let request = BGProcessingTaskRequest(identifier: TaskIdentifiers.backgroundProcessing)
        
        // Fetch no earlier than 15 sec from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 5)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            debugLog("scheduleProcessingSync: OK")
        } catch {
            print("Could not schedule app refresh: \(error)")
            debugLog("scheduleProcessingSync: Could not schedule app Processing: \(error)")
        }
    }
    
    func scheduleRefreshSync() {
        
        let request = BGProcessingTaskRequest(identifier: TaskIdentifiers.backgroundRefresh)
        
        // Fetch no earlier than 15 sec from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 5)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
             debugLog("scheduleRefreshSync: OK")
        } catch {
            debugLog("scheduleRefreshSync: Could not schedule app refresh: \(error)")
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleProcessingSyncTask(task: BGProcessingTask) {
        debugLog("handleProcessingSyncTask")
        
        guard LocalMediaStorage.default.photoLibraryIsAvailible(), storageVars.autoSyncSet else {
            debugLog("handleProcessingSyncTask_LibraryAccess_or_AutoSync")
            return
        }
        
        SyncServiceManager.shared.backgroundTaskSync { isLast in
            debugLog("handleProcessingSyncTask_task_completed")
            task.setTaskCompleted(success: isLast)
        }
        
        task.expirationHandler = {
            debugLog("handleProcessingSyncTask_expirationHandler")
            SyncServiceManager.shared.stopSync()
        }
    }
    
    private func handleRefreshSyncTask(task: BGAppRefreshTask) {
        scheduleRefreshSync()
        debugLog("handleRefreshSyncTask")
        guard LocalMediaStorage.default.photoLibraryIsAvailible(), storageVars.autoSyncSet else {
            debugLog("handleRefreshSyncTask_LibraryAccess_or_AutoSync")
            return
        }
        
        SyncServiceManager.shared.backgroundTaskSync { isLast in
            debugLog("handleRefreshSyncTask_task_completed")
            task.setTaskCompleted(success: isLast)
        }
        
        task.expirationHandler = {
            debugLog("handleRefreshSyncTask_expirationHandler")
            SyncServiceManager.shared.stopSync()
        }
    }
    
}
