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
extension BackgroundSyncService {
    static let shared = BackgroundSyncService()
}

@available(iOS 13.0, *)
final class BackgroundSyncService {
    
    private enum TaskIdentifiers {
        static let backgroundProcessing = "background_processing"
        static let backgroundRefresh = "background_refresh"
    }
    
    //MARK: Service
    private lazy var accountService: AccountServicePrl = AccountService()
    private lazy var storageVars: StorageVars = factory.resolve()
    
    private static let schedulerQueue = DispatchQueue(label: DispatchQueueLabels.backgroundTaskSyncQueue)
    
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func registerLaunchHandlers() {
        debugLog("BG! register processing task")
        registerTask(identifier: TaskIdentifiers.backgroundProcessing, queue: BackgroundSyncService.schedulerQueue)
        debugLog("BG! register resfresh task")
        registerTask(identifier: TaskIdentifiers.backgroundRefresh, queue: BackgroundSyncService.schedulerQueue)
    }
    
    private func registerTask(identifier: String, queue: DispatchQueue) {
        let isRegistered = BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: queue) { [weak self] task in
            self?.handleBGtask(task)
        }
        debugLog("BG! is task \(identifier) registered \(isRegistered)")
    }
    
    func cancelAllTasks() {
        debugLog("BG! cancel all tasks")
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    func handleBGtask(_ task: BGTask) {
        debugLog("BG! handleTask \(task.identifier) isBG \(ApplicationStateHelper.shared.isBackground)")
        sendNetmeraEvent(type: task.identifier)
        guard
            LocalMediaStorage.default.photoLibraryIsAvailible(),
            storageVars.isAutoSyncSet,
            ApplicationStateHelper.shared.isBackground
        else {
            debugLog("BG! DECLINED: Photo \(LocalMediaStorage.default.photoLibraryIsAvailible()) and autosync \(storageVars.isAutoSyncSet) is disabled and isBackground \(ApplicationStateHelper.shared.isBackground) for \(task.identifier)")
            
            scheduleTask(taskIdentifier: task.identifier)
            
            task.setTaskCompleted(success: false)
            
            return
        }
        
        let backgroundOperation: BackgroundSyncOperation
        
        if task.identifier == TaskIdentifiers.backgroundProcessing {
            ///Currently they both use same task
            backgroundOperation = BackgroundSyncOperation()
            operationQueue.cancelAllOperations()
        } else if task.identifier == TaskIdentifiers.backgroundRefresh {
            backgroundOperation = BackgroundSyncOperation()
        } else {
            debugLog("BG! ERROR: task not recognised")
            return
        }
        
        operationQueue.addOperation(backgroundOperation)
        
        task.expirationHandler = {
            debugLog("BG! task expired \(task.identifier)")
            backgroundOperation.cancel()
        }
        
        backgroundOperation.completionBlock = {
            debugLog("BG! task complited \(task.identifier) was cannceled ? \(backgroundOperation.isCancelled)")
            task.setTaskCompleted(success: !backgroundOperation.isCancelled)
        }
        
        scheduleTask(taskIdentifier: task.identifier)
        
    }
    
    private func scheduleTask(taskIdentifier: String) {
        let settings = AutoSyncDataStorage().settings
        
        guard settings.isAutoSyncEnabled || !CacheManager.shared.isCacheActualized else {
            return
        }
        
        debugLog("BG! scheduleTask \(taskIdentifier)")
        let request: BGTaskRequest
        
        if taskIdentifier == TaskIdentifiers.backgroundProcessing {
            
            request = BGProcessingTaskRequest(identifier: TaskIdentifiers.backgroundProcessing)
            
            if let processingTask = request as? BGProcessingTaskRequest {
                processingTask.requiresNetworkConnectivity = true
                processingTask.requiresExternalPower = false
            }
        } else if taskIdentifier == TaskIdentifiers.backgroundRefresh {
            request = BGAppRefreshTaskRequest(identifier: TaskIdentifiers.backgroundRefresh)
        } else {
            debugLog("BG! ERROR: trying to schedule unknown ID task")
            return
        }
        
        // Fetch no earlier than 15 sec from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 20 * 5)
        debugLog("BG! scheduleTask \(taskIdentifier) request created")
        
        do {
            try BGTaskScheduler.shared.submit(request)
            debugLog("BG! task scheduled \(taskIdentifier)")
        } catch {
            debugLog("BG! ERROR task \(taskIdentifier) schedule failed \(error)")
        }
        
    }
    
    func scheduleProcessingSync() {
        scheduleTask(taskIdentifier: TaskIdentifiers.backgroundProcessing)
    }
    
    func scheduleRefreshSync() {
        scheduleTask(taskIdentifier: TaskIdentifiers.backgroundRefresh)
    }
    
    private func sendNetmeraEvent(type: String) {
        DispatchQueue.main.async {
            debugLog("BG! Netmera event")
            let event = NetmeraEvents.Actions.BackgroundSync(syncType: .backgroundTask(type: type))
            AnalyticsService.sendNetmeraEvent(event: event)
        }
    }
}
