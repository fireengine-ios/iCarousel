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
extension BackgroundSynсService {
    static let backgroundSynсService = BackgroundSynсService()
}

@available(iOS 13.0, *)
final class BackgroundSynсService {
    
    private enum TaskIdentifiers {
        static let backgroundProcessing = "background_processing"
        static let backgroundRefresh = "background_refresh"
    }
    
    //MARK: Service
    private lazy var accountService: AccountServicePrl = AccountService()
    private lazy var storageVars: StorageVars = factory.resolve()
    
    private static let schedulerQueue = DispatchQueue(label: DispatchQueueLabels.backgroundTaskSyncQueue)
    private let syncServiceManager = SyncServiceManager.shared
    
    func registerLaunchHandlers() {
        
        registerTask(identifier: TaskIdentifiers.backgroundProcessing, queue: BackgroundSynсService.schedulerQueue)
        registerTask(identifier: TaskIdentifiers.backgroundRefresh, queue: BackgroundSynсService.schedulerQueue)
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: TaskIdentifiers.backgroundProcessing, using: BackgroundSynсService.schedulerQueue) { task in
            
//            guard let task = task as? BGProcessingTask else {
//                return
//            }
//           self.handleProcessingSyncTask(task: task)
//        }
//
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: TaskIdentifiers.backgroundRefresh, using: BackgroundSynсService.schedulerQueue) { task in
//
//
//            guard let task = task as? BGAppRefreshTask else {
//                return
//            }
//            self.handleRefreshSyncTask(task: task)
//        }
    }
    
    private func registerTask(identifier: String, queue: DispatchQueue) {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: queue) { [weak self] task in
            self?.handleBGtask(task)
        }
    }
    
    func handleBGtask(_ task: BGTask) {
        guard CoreDataStack.shared.isReady else {
            task.setTaskCompleted(success: false)
            return
        }
        debugLog("BG! handleTask \(task.identifier)")

        guard
            LocalMediaStorage.default.photoLibraryIsAvailible(),
            storageVars.autoSyncSet
        else {
            debugLog("BG! DECLINED Photo \(LocalMediaStorage.default.photoLibraryIsAvailible()) and autosync \(storageVars.autoSyncSet) is disabled for \(task.identifier)")
            return
        }
        
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        if task.identifier == TaskIdentifiers.backgroundProcessing {
//actualize cash first then AS
            //
            let appRefreshOperation = BackgroundRefreshOperation()
            queue.addOperation(appRefreshOperation)
            //
            
            scheduleProcessingSync()
            
        } else if task.identifier == TaskIdentifiers.backgroundRefresh {
            let appRefreshOperation = BackgroundRefreshOperation()
            queue.addOperation(appRefreshOperation)
            scheduleRefreshSync()
        } else {
            debugLog("BG! not recognizable task")
            return
        }
        
        
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//        let appRefreshOperation = AppRefreshOperation()
//        queue.addOperation(appRefreshOperation)
//
        task.expirationHandler = {
            debugLog("BG! task expired \(task.identifier)")
            queue.cancelAllOperations()
        }

        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            debugLog("BG! task complited \(task.identifier)")
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }
//
//        scheduleAppRefresh()
        
    }
    
    func scheduleProcessingSync() {
        
        let request = BGProcessingTaskRequest(identifier: TaskIdentifiers.backgroundProcessing)
        
        // Fetch no earlier than 15 sec from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 20 * 5)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            debugLog("BG! scheduleProcessingSync: OK")
        } catch {
            debugLog("BG! scheduleProcessingSync: Could not schedule app Processing: \(error)")
        }
    }
    
    func scheduleRefreshSync() {
        
        let request = BGAppRefreshTaskRequest(identifier: TaskIdentifiers.backgroundRefresh)
        
        // Fetch no earlier than 15 sec from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 20 * 5)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            debugLog("BG! scheduleRefreshSync: OK")
        } catch {
            debugLog("BG! scheduleRefreshSync: Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleProcessingSyncTask(task: BGProcessingTask) {
        debugLog("handleProcessingSyncTask")
        scheduleProcessingSync()
        
        guard LocalMediaStorage.default.photoLibraryIsAvailible(), storageVars.autoSyncSet else {
            debugLog("handleProcessingSyncTask_LibraryAccess_or_AutoSync")
            return
        }
        
        SyncServiceManager.shared.backgroundTaskSync { isLast in
            debugLog("handleProcessingSyncTask_task_completed")
            task.setTaskCompleted(success: isLast)
            self.scheduleProcessingSync()
        }
        
        task.expirationHandler = {
            debugLog("handleProcessingSyncTask_expirationHandler")
            SyncServiceManager.shared.stopSync()
            self.scheduleProcessingSync()
        }
    }
    
    private func handleRefreshSyncTask(task: BGAppRefreshTask) {
        scheduleRefreshSync()
        debugLog("handleRefreshSyncTask")
        guard LocalMediaStorage.default.photoLibraryIsAvailible(), storageVars.autoSyncSet else {
            debugLog("handleRefreshSyncTask_LibraryAccess_or_AutoSync")
            return
        }
        
        syncServiceManager.backgroundTaskSync { isLast in
            debugLog("handleRefreshSyncTask_task_completed")
            self.scheduleRefreshSync()
            task.setTaskCompleted(success: isLast)
        }
        
        task.expirationHandler = {
            self.scheduleRefreshSync()
            debugLog("handleRefreshSyncTaskk_expirationHandler")
        }
    }
    
}
