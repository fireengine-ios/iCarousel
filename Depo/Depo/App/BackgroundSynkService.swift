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
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func scheduleRefreshSync() {
        
        let request = BGProcessingTaskRequest(identifier: TaskIdentifiers.backgroundRefresh)
        
        // Fetch no earlier than 15 sec from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
        
   private func handleProcessingSyncTask(task: BGProcessingTask) {
        
        let request = BGProcessingTaskRequest(identifier: TaskIdentifiers.backgroundProcessing)
        
        // Fetch no earlier than 15 sec from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
        
    }
    
    private func handleRefreshSyncTask(task: BGAppRefreshTask) {
        scheduleRefreshSync()
        
        guard LocalMediaStorage.default.photoLibraryIsAvailible(), storageVars.autoSyncSet else {
            return
        }
        
        SyncServiceManager.shared.backgroundTaskSync { isLast in
            task.setTaskCompleted(success: isLast)
        }
        
        task.expirationHandler = {
            SyncServiceManager.shared.stopSync()
        }
    }
    
}
