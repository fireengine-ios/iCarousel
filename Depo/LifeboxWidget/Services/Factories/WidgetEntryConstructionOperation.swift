//
//  WidgetEntryConstructionOperation.swift
//  Depo
//
//  Created by Alex Developer on 09.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

final class WidgetEntryConstructionOperation: Operation {
    
    private let semaphore = DispatchSemaphore(value: 0)
    let ordersCehckList: [WidgetStateOrder]
    let callback: WidgetBaseEntryAndOrderCallback
    var customCurrentDate: Date?
    
    init(ordersCehckList: [WidgetStateOrder], customCurrentDate: Date? = nil, callback: @escaping WidgetBaseEntryAndOrderCallback) {
        self.callback = callback
        self.ordersCehckList = ordersCehckList
        self.customCurrentDate = customCurrentDate
    }
    
    override func main() {
        guard !isCancelled else {
            return
        }
        findFirstFittingEntry(orders: ordersCehckList, customCurrentDate: customCurrentDate) { [weak self] (entry, order) in
            guard let self = self else {
                return
            }
            guard !self.isCancelled else {
                self.semaphore.signal()
                return
            }
            self.callback(entry,order)
            self.semaphore.signal()
        }
        semaphore.wait()
    }
    
    private func findFirstFittingEntry(orders: [WidgetStateOrder], customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryAndOrderCallback) {

        var ordersCheckList = orders
        
        if let firstOrderToCheck = ordersCheckList.first {
            ordersCheckList.removeFirst()
            self.checkOrder(order: firstOrderToCheck, customCurrentDate: customCurrentDate) { [weak self] preparedEntry in
                guard let self = self else {
                    return
                }
                guard !self.isCancelled else {
                    self.semaphore.signal()
                    return
                }
                guard let preparedEntry = preparedEntry else {
                    self.findFirstFittingEntry(orders: ordersCheckList, customCurrentDate: customCurrentDate, entryCallback: entryCallback)
                    //recurtion
                    return
                }
                entryCallback(preparedEntry, firstOrderToCheck)
            }
        } else {
            entryCallback(nil, nil)
        }
    }
    
    private func checkOrder(order: WidgetStateOrder, customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryCallback) {
        guard !self.isCancelled else {
            self.semaphore.signal()
            return
        }
        DebugLogService.debugLog("Checking ORDER: \(order)")
        
        switch order {
        case .login:
            //ORDER-0
            checkLoginStatus(customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .quota:
            //ORDER-1
            checkQuotaStatus(customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .freeUpSpace:
            //ORDER-2
            checkStorageStatus(customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .syncInProgress, .syncComplete:
            //ORDER-3
            //sync complete related to ORDER -3
            checkSyncInProgres(customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .autosync:
            //ORDER-4
            checkSyncStatus(customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .contactsNoBackup, .oldContactsBackup:
            //ORDER-5 (No contact backup):
            //ORDER-6 (Last backup is older than 1 month):
            checkContactBackupStatus(customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        case .fir:
            //ORDER-7
            checkFIRStatus(customCurrentDate: customCurrentDate, entryCallback: entryCallback)
        }
    }
    
}

//MARK:- orders specific check
extension WidgetEntryConstructionOperation {
    //ORDER-0
    ///Check if the user is login to the app or not. If the user is not login, display this widget: https://zpl.io/brwelx1
    private func checkLoginStatus(customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryCallback) {
        let startDate = customCurrentDate ?? Date()
        WidgetPresentationService.shared.isAuthorized ? entryCallback(nil) : entryCallback(WidgetLoginRequiredEntry(date: startDate))
    }
    
    //ORDER-1
    ///Check user's lifebox storage quota.
    ///When a user's lifebox quota is (%75-%100) full, we will display this widget: https://zpl.io/VDyr45J
    private func checkQuotaStatus(customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryCallback) {
        let startDate = customCurrentDate ?? Date()
        WidgetPresentationService.shared.getStorageQuota { usedPercentage in
            entryCallback(usedPercentage >= 75 ? WidgetQuotaEntry(usedPercentage: usedPercentage, date: startDate) : nil)
        }
    }
    
    //ORDER-2
    ///Check user's device storage.
    ///When a user's device storage is (%75-%100) full, we will display this widget: https://zpl.io/V4W4QZ4
    private func checkStorageStatus(customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryCallback) {
        let startDate = customCurrentDate ?? Date()
        WidgetPresentationService.shared.getDeviceStorageQuota { usedPercentage in
            entryCallback(usedPercentage >= 75 ? WidgetDeviceQuotaEntry(usedPercentage: usedPercentage, date: startDate) : nil)
        }
    }
    
    //ORDER-3
    ///Check if any sync is in progress (manaul, auto, background, upload to lifebox via native share)
    ///Please write 1/x, 2/x on the widget and file name during syncing and display this widget:  https://zpl.io/VYOxGPn
    private func checkSyncInProgres(customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryCallback) {
        guard
            WidgetPresentationService.shared.isPreparationFinished,
            WidgetPresentationService.shared.isPhotoLibriaryAvailable()
        else {
            entryCallback(nil)
            return
        }
        let startDate = customCurrentDate ?? Date()
        let syncInfo = WidgetPresentationService.shared.getSyncInfo()
        if syncInfo.syncStatus == .executing {
            entryCallback(WidgetSyncInProgressEntry(uploadCount: syncInfo.uploadCount,
                                                    totalCount: syncInfo.totalCount,
                                                    currentFileName: syncInfo.currentSyncFileName,
                                                    date: startDate))
        } else if syncInfo.syncStatus == .synced,
                  let lastSyncDate = syncInfo.lastSyncedDate,
                  lastSyncDate.timeIntervalSince(Date()) < 20 {
            entryCallback(WidgetSyncInProgressEntry(isSyncCompleted: true, date: startDate))
        } else {
            entryCallback(nil)
        }
        
    }
    
    //ORDER-4 (Checking unsynced files)
    ///Check if there are unsynced files in device gallery and auto sync value ON or OFF.
    private func checkSyncStatus(customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryCallback) {
        guard
            WidgetPresentationService.shared.isPreparationFinished,
            WidgetPresentationService.shared.isPhotoLibriaryAvailable()
        else {
            DebugLogService.debugLog("ORDER 4: gallery is unavailable")
            entryCallback(nil)
            return
        }
        
        DebugLogService.debugLog("ORDER 4: preparation is finished \(WidgetPresentationService.shared.isPreparationFinished)")
        
        let startDate = customCurrentDate ?? Date()
        WidgetPresentationService.shared.hasUnsyncedItems { hasUnsynced in
            DebugLogService.debugLog("ORDER 4: hasUnsynced \(hasUnsynced)")
            let syncInfo = WidgetPresentationService.shared.getSyncInfo()
            
            guard hasUnsynced, syncInfo.syncStatus != .executing else {
                DebugLogService.debugLog("ORDER 4: sync is executing")
                entryCallback(nil)
                return
            }
            
            DebugLogService.debugLog("ORDER 4: isAutoSyncEnabled \(syncInfo.isAutoSyncEnabled)")
            
            entryCallback(WidgetAutoSyncEntry(isSyncEnabled: syncInfo.isAutoSyncEnabled, date: startDate))
        }
    }
    
    //ORDER-5 (No contact backup):
    ///Check if user has a a contact backup.
    ///If user has no backup in lifebox, we will display this widget: https://zpl.io/2GZY9nj
    //ORDER-6 (Last backup is older than 1 month)
    ///Check if user has a contact backup and its date.
    private func checkContactBackupStatus(customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryCallback) { //no cantact backup or last backup older > 1 month

        let startDate = customCurrentDate ?? Date()
        
        WidgetPresentationService.shared.getContactBackupStatus { response in
            guard let response = response else {
                entryCallback(nil)
                return
            }
            
            let todayDate = Date()
            guard let backupDate = response.date, response.totalNumberOfContacts > 0 else {
                return entryCallback(WidgetContactBackupEntry(date: startDate))
            }
            
            let components = Calendar.current.dateComponents([.month], from: backupDate, to: todayDate)
            if components.month! >= 1 {
                entryCallback(WidgetContactBackupEntry(backupDate: response.date, date: startDate))
            } else {
                entryCallback(nil)
            }
        }
    }
    
    //ORDER-7 (Face Recognition):
    ///Check if user has AUTH_FACE_IMAGE_LOCATION authority with calling authority API and check if user's face-image recognition is enabled or not
    private func checkFIRStatus(customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryCallback) {
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
                peopleInfos: response.userInfo.peopleInfos,
                date: date
            )
            entryCallback(entry)
        }
    }
}
