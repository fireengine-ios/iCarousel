//
//  WidgetEntryConstructionOperation.swift
//  Depo
//
//  Created by Alex Developer on 09.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

enum EntryCreationOperationError: Error {
    case notFittingEntry
    case cancel
    case error(Error)
}

typealias FittingEntryResult = (Result<(WidgetBaseEntry, WidgetStateOrder), EntryCreationOperationError>) -> Void

import Foundation

final class WidgetEntryConstructionOperation: Operation {
    
    private let semaphore = DispatchSemaphore(value: 0)
    let ordersCheckList: [WidgetStateOrder]
    let callback: EntryCreationResultCallback
    var customCurrentDate: Date?
    
    init(ordersCheckList: [WidgetStateOrder], customCurrentDate: Date? = nil, callback: @escaping EntryCreationResultCallback) {
        self.callback = callback
        self.ordersCheckList = ordersCheckList
        self.customCurrentDate = customCurrentDate
    }
    
    override func main() {
        guard !isCancelled else {
            self.callback(.failure(.cancel))
            return
        }
        findFirstFittingEntry(orders: ordersCheckList, customCurrentDate: customCurrentDate) { [weak self] result in
            guard let self = self else {
                return
            }
            guard !self.isCancelled else {
                self.callback(.failure(.cancel))
                self.semaphore.signal()
                return
            }

            switch result {
            case .success((let entry, let order)):
                self.callback(.success((entry,order)))
            case .failure(let failureStatus):
                switch failureStatus {
                case .cancel:
                    self.callback(.failure(.cancel))
                case .error(let error):
                    self.callback(.failure(.error(error)))
                case .notFittingEntry:
                    self.callback(.failure(.noEntryFound))
                }
            }
            self.semaphore.signal()
        }
        semaphore.wait()
    }
    
    private func findFirstFittingEntry(orders: [WidgetStateOrder], customCurrentDate: Date? = nil, entryCallback: @escaping FittingEntryResult) {

        var ordersCheckList = orders
        
        if let firstOrderToCheck = ordersCheckList.first {
            ordersCheckList.removeFirst()
            self.checkOrder(order: firstOrderToCheck, customCurrentDate: customCurrentDate) { [weak self] result in
                guard let self = self else {
                    return
                }
                guard !self.isCancelled else {
                    self.semaphore.signal()
                    self.callback(.failure(.cancel))
                    return
                }
                
                switch result {
                case .success((let entry, let order)):
                    entryCallback(.success((entry, order)))
                case .failure(let failureStatus):
                    switch failureStatus {
                    case .cancel:
                        entryCallback(.failure(.cancel))
                    case .error(let error):
                        entryCallback(.failure(.error(error)))
                    case .notFittingEntry:
                        self.findFirstFittingEntry(orders: ordersCheckList, customCurrentDate: customCurrentDate, entryCallback: entryCallback)
                    }
                }
            }
        } else {
            entryCallback(.failure(.notFittingEntry))
        }
    }
    
    private func checkOrder(order: WidgetStateOrder, customCurrentDate: Date? = nil, entryCallback: @escaping FittingEntryResult) {
        guard !self.isCancelled else {
            self.callback(.failure(.cancel))
            self.semaphore.signal()
            return
        }
        DebugLogService.debugLog("Checking ORDER: \(order)")
        
        switch order {
        case .login:
            //ORDER-0
            checkLoginStatus(order: order, customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .quota:
            //ORDER-1
            checkQuotaStatus(order: order, customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .freeUpSpace:
            //ORDER-2
            checkStorageStatus(order: order, customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .syncInProgress, .syncComplete:
            //ORDER-3
            //sync complete related to ORDER -3
            checkSyncInProgres(order: order, customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .autosync:
            //ORDER-4
            checkSyncStatus(order: order, customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .contactsNoBackup, .oldContactsBackup:
            //ORDER-5 (No contact backup):
            //ORDER-6 (Last backup is older than 1 month):
            checkContactBackupStatus(order: order, customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .fir:
            //ORDER-7
            checkFIRStatus(order: order, customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        }
    }
    
}

//MARK:- orders specific check
extension WidgetEntryConstructionOperation {
    //ORDER-0
    ///Check if the user is login to the app or not. If the user is not login, display this widget: https://zpl.io/brwelx1
    private func checkLoginStatus(order: WidgetStateOrder, customCurrentDate: Date? = nil, entryCallback: @escaping FittingEntryResult) {
        let startDate = customCurrentDate ?? Date()
        WidgetPresentationService.shared.isAuthorized ? entryCallback(.failure(.notFittingEntry)) : entryCallback(.success((WidgetLoginRequiredEntry(date: startDate), order)))
    }
    
    //ORDER-1
    ///Check user's lifebox storage quota.
    ///When a user's lifebox quota is (%75-%100) full, we will display this widget: https://zpl.io/VDyr45J
    private func checkQuotaStatus(order: WidgetStateOrder, customCurrentDate: Date? = nil, entryCallback: @escaping FittingEntryResult) {
        let startDate = customCurrentDate ?? Date()
        WidgetPresentationService.shared.getStorageQuota { usedPercentage in
                entryCallback(usedPercentage >= 75 ? .success((WidgetQuotaEntry(usedPercentage: usedPercentage, date: startDate), order )): .failure(.notFittingEntry))
        }
    }
    
    //ORDER-2
    ///Check user's device storage.
    ///When a user's device storage is (%75-%100) full, we will display this widget: https://zpl.io/V4W4QZ4
    private func checkStorageStatus(order: WidgetStateOrder, customCurrentDate: Date? = nil, entryCallback: @escaping FittingEntryResult) {
        let startDate = customCurrentDate ?? Date()
        WidgetPresentationService.shared.getDeviceStorageQuota { usedPercentage in
            entryCallback(usedPercentage >= 75 ? .success((WidgetDeviceQuotaEntry(usedPercentage: usedPercentage, date: startDate), order)) : .failure(.notFittingEntry))
        }
    }
    
    //ORDER-3
    ///Check if any sync is in progress (manaul, auto, background, upload to lifebox via native share)
    ///Please write 1/x, 2/x on the widget and file name during syncing and display this widget:  https://zpl.io/VYOxGPn
    private func checkSyncInProgres(order: WidgetStateOrder, customCurrentDate: Date? = nil, entryCallback: @escaping FittingEntryResult) {
        guard
            WidgetPresentationService.shared.isPreparationFinished,
            WidgetPresentationService.shared.isPhotoLibriaryAvailable()
        else {
            debugPrint("!!! SYNC IS NOT IN PROGRESS")
            entryCallback(.failure(.notFittingEntry))
            return
        }
        let startDate = customCurrentDate ?? Date()
        let syncInfo = WidgetPresentationService.shared.getSyncInfo()
        
        switch syncInfo.syncStatus {
        case .executing:
            debugPrint("!!! SYNC executing")
            entryCallback(.success((WidgetSyncInProgressEntry(uploadCount: syncInfo.uploadCount,
                                                    totalCount: syncInfo.totalCount,
                                                    currentFileName: syncInfo.currentSyncFileName,
                                                    date: startDate), order)))
        case .synced:
            debugPrint("!!! SYNC SYNCHED")
            guard syncInfo.syncStatus == syncInfo.shownSyncStatus else {
                entryCallback(.success((WidgetSyncInProgressEntry(isSyncCompleted: true, date: startDate), order)))
                WidgetPresentationService.shared.save(shownSyncStatus: syncInfo.syncStatus)
                return
            }
            
            //allows to show isSyncCompleted for some time after it's completed
            if let lastSyncDate = syncInfo.lastSyncedDate, Date().timeIntervalSince(lastSyncDate) < 8 {
                debugPrint("!!! SYNC SYNCHED < 8")
                entryCallback(.success((WidgetSyncInProgressEntry(isSyncCompleted: true, date: startDate), order)))
            } else {
                entryCallback(.failure(.notFittingEntry))
            }
            
        default:
            entryCallback(.failure(.notFittingEntry))
        }
        
        WidgetPresentationService.shared.save(shownSyncStatus: syncInfo.syncStatus)
        
    }
    
    //ORDER-4 (Checking unsynced files)
    ///Check if there are unsynced files in device gallery and auto sync value ON or OFF.
    private func checkSyncStatus(order: WidgetStateOrder, customCurrentDate: Date? = nil, entryCallback: @escaping FittingEntryResult) {
        guard
            WidgetPresentationService.shared.isPreparationFinished,
            WidgetPresentationService.shared.isPhotoLibriaryAvailable()
        else {
            DebugLogService.debugLog("ORDER 4: gallery is unavailable")
            entryCallback(.failure(.notFittingEntry))
            return
        }
        
        DebugLogService.debugLog("ORDER 4: preparation is finished \(WidgetPresentationService.shared.isPreparationFinished)")
        
        let startDate = customCurrentDate ?? Date()
        WidgetPresentationService.shared.hasUnsyncedItems { hasUnsynced in
            DebugLogService.debugLog("ORDER 4: hasUnsynced \(hasUnsynced)")
            let syncInfo = WidgetPresentationService.shared.getSyncInfo()
            
            guard hasUnsynced else { //, syncInfo.syncStatus != .executing
                DebugLogService.debugLog("ORDER 4: sync status \(syncInfo.syncStatus)")
                entryCallback(.failure(.notFittingEntry))
                return
            }
            
            DebugLogService.debugLog("ORDER 4: isAutoSyncEnabled \(syncInfo.isAutoSyncEnabled)")
            
            entryCallback(.success((WidgetAutoSyncEntry(isSyncEnabled: syncInfo.isAutoSyncEnabled, date: startDate), order)))
        }
    }
    
    //ORDER-5 (No contact backup):
    ///Check if user has a a contact backup.
    ///If user has no backup in lifebox, we will display this widget: https://zpl.io/2GZY9nj
    //ORDER-6 (Last backup is older than 1 month)
    ///Check if user has a contact backup and its date.
    private func checkContactBackupStatus(order: WidgetStateOrder, customCurrentDate: Date? = nil, entryCallback: @escaping FittingEntryResult) { //no cantact backup or last backup older > 1 month

        let startDate = customCurrentDate ?? Date()
        
        WidgetPresentationService.shared.getContactBackupStatus { response in
            guard let response = response else {
                entryCallback(.failure(.notFittingEntry))
                return
            }
            
            let todayDate = Date()
            guard let backupDate = response.date, response.totalNumberOfContacts > 0 else {
                return entryCallback(.success((WidgetContactBackupEntry(date: startDate), order)))
            }
            
            let components = Calendar.current.dateComponents([.month], from: backupDate, to: todayDate)
            if components.month! >= 1 {
                entryCallback(.success((WidgetContactBackupEntry(backupDate: response.date, date: startDate), order)))
            } else {
                entryCallback(.failure(.notFittingEntry))
            }
        }
    }
    
    //ORDER-7 (Face Recognition):
    ///Check if user has AUTH_FACE_IMAGE_LOCATION authority with calling authority API and check if user's face-image recognition is enabled or not
    private func checkFIRStatus(order: WidgetStateOrder, customCurrentDate: Date? = nil, entryCallback: @escaping FittingEntryResult) {
        //TODO: isFIREnabled - check if being created correctly
        
        let startDate = customCurrentDate ?? Date()
        
        WidgetPresentationService.shared.getFIRStatus { response in
            let date: Date
            if response.isLoadingImages {
                date = Calendar.current.date(byAdding: .second, value: 10, to: startDate) ?? startDate
            } else {
                date = Calendar.current.date(byAdding: .second, value: 2, to: startDate) ?? startDate
            }
            
            let entry = WidgetUserInfoEntry(
                isFIREnabled: response.userInfo.isFIREnabled,
                hasFIRPermission: response.userInfo.hasFIRPermission,
                imageUrls: response.userInfo.imageUrls,
                date: date
            )
            entryCallback(.success((entry, order)))
        }
    }
}
