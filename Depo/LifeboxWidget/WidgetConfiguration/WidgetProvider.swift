//
//  WidgetProvider.swift
//  Depo
//
//  Created by Roman Harhun on 01/09/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation
import SwiftUI
import WidgetKit


typealias WidgetBaseEntriesCallback = ([WidgetBaseEntry]) -> ()
typealias WidgetBaseEntryCallback = (WidgetBaseEntry?) -> ()
typealias WidgetBaseEntryAndOrderCallback = (_ entry: WidgetBaseEntry?, _ order: WidgetStateOrder?) -> ()
typealias WidgetTimeLineCallback = (Timeline<WidgetBaseEntry>) -> Void

//MARK:- widget general
final class WidgetProvider: TimelineProvider {
    typealias Entry = WidgetBaseEntry
    let defaultOrdersCheckList: [WidgetStateOrder] = [.login, .quota, .freeUpSpace, .syncInProgress, .autosync, .contactsNoBackup, .fir]
    
    private var isTimelinePreparedSmall = true
    private var isTimelinePreparedMedium = true

    private let privateQueue = DispatchQueue(label: DispatchQueueLabels.widgetProviderQueue)
    
    func placeholder(in context: Context) -> WidgetBaseEntry {
        if let entry = WidgetPresentationService.shared.lastWidgetEntry {
            return entry
        }
        return WidgetLoginRequiredEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetBaseEntry) -> Void) {
        if let entry = WidgetPresentationService.shared.lastWidgetEntry {
            completion(entry)
            return
        }
        
        getTimeline(in: context) { timeline in
            if let entry = timeline.entries.first {
                completion(entry)
            } else {
                completion(WidgetLoginRequiredEntry(date: Date()))
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping WidgetTimeLineCallback) {
        switch context.family {
        case .systemSmall:
            if !isTimelinePreparedSmall {
                return
            }
            isTimelinePreparedSmall = false
            
        case .systemMedium:
            if !isTimelinePreparedMedium {
                return
            }
            isTimelinePreparedMedium = false
        default:
            break
        }

        calculateCurrentOrderTimeline(family: context.family, timelineCallback: completion)
    }
}

//MARK:- widget order check
extension WidgetProvider {
    
    private func calculateCurrentOrderTimeline(family: WidgetFamily, timelineCallback: @escaping WidgetTimeLineCallback) {
        privateQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.findFirstFittingEntry(orders: self.defaultOrdersCheckList) { [weak self] preparedEntry, order in
                self?.privateQueue.async { [weak self] in
                    guard
                        let self = self,
                        let preparedEntry = preparedEntry,
                        let order = order
                    else {
                        assertionFailure("there should be atleast one entry")
                        return
                    }
                    
                    var entries = [WidgetBaseEntry]()
                    entries.append(preparedEntry)
                    
                    if order.isContained(in: [.syncInProgress, .syncComplete]),
                       preparedEntry.state == .syncComplete,
                       let slice = self.defaultOrdersCheckList.split(separator: order).last {
                        
                        let nextOrdersInLine: [WidgetStateOrder] = Array(slice)
                        
                        self.findFirstFittingEntry(orders: nextOrdersInLine, customCurrentDate: order.refreshDate) { (nextEntry, entryOrder) in
                            if let newEntry = nextEntry {
                                entries.append(newEntry)
                            }
                            semaphore.signal()
                        }
                        semaphore.wait()
                    }
                    
                    if family == .systemSmall {
                        self.isTimelinePreparedSmall = true
                    } else {
                        self.isTimelinePreparedMedium = true
                    }
                    self.save(entry: entries.last)
                    
                    timelineCallback(self.prepareTimeline(order: order, entries: entries))
                }
            }
        }
    }
    
    private func prepareTimeline(order: WidgetStateOrder, entries: [WidgetBaseEntry]) -> Timeline<WidgetBaseEntry> {
        switch order {
        case .login: //ORDER-0
            return Timeline(entries: entries, policy: .never)
        case .quota, .freeUpSpace, .autosync, .contactsNoBackup, .oldContactsBackup, .fir, .syncInProgress, .syncComplete:  //ORDER 1-7
            let refreshDate = order.refreshDate ?? Date()
            return  Timeline(entries: entries, policy: .after(refreshDate))
        }
    }

    private func findFirstFittingEntry(orders: [WidgetStateOrder], customCurrentDate: Date? = nil, entryCallback: @escaping WidgetBaseEntryAndOrderCallback) {

        var ordersCheckList = orders
        
        if let firstOrderToCheck = ordersCheckList.first {
            ordersCheckList.removeFirst()
            self.checkOrder(order: firstOrderToCheck, customCurrentDate: customCurrentDate) { [weak self] preparedEntry in
                guard let preparedEntry = preparedEntry else {
                    self?.findFirstFittingEntry(orders: ordersCheckList, customCurrentDate: customCurrentDate, entryCallback: entryCallback)
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
    
    private func save(entry: WidgetBaseEntry?) {
        if let entry = entry, WidgetPresentationService.shared.lastWidgetEntry?.state != entry.state {
            WidgetPresentationService.shared.notifyChangeWidgetState(entry.state)
        }
        
        WidgetPresentationService.shared.lastWidgetEntry = entry
    }
    
}

//MARK:- widget entry constraction
extension WidgetProvider {

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
            WidgetPresentationService.shared.isPreperationFinished,
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
            WidgetPresentationService.shared.isPreperationFinished,
            WidgetPresentationService.shared.isPhotoLibriaryAvailable()
        else {
            entryCallback(nil)
            return
        }
        let startDate = customCurrentDate ?? Date()
        WidgetPresentationService.shared.hasUnsyncedItems { hasUnsynced in
            //TODO: need to check case if deleted remotes after sync
            if hasUnsynced {
                let syncInfo = WidgetPresentationService.shared.getSyncInfo()
                if syncInfo.isAppLaunch && syncInfo.isAutoSyncEnabled {
                    //this case for order 3 - sync in progress
                    entryCallback(nil)
                    return
                }
                
                entryCallback(WidgetAutoSyncEntry(isSyncEnabled: syncInfo.isAutoSyncEnabled, date: startDate))
            } else {
                entryCallback(nil)
            }
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

