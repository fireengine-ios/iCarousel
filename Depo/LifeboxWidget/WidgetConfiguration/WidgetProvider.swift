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
typealias WidgetTimeLineCallback = (Timeline<WidgetBaseEntry>) -> Void

//MARK:- widget general
final class WidgetProvider: TimelineProvider {
    typealias Entry = WidgetBaseEntry
    private static let timeStep = 2
    
    private var isTimelinePreparedSmall = true
    private var isTimelinePreparedMedium = true

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
        
        let ordersCheckList: [WidgetStateOrder] = [.contactsNoBackup, .login, .quota, .freeUpSpace, .syncInProgress, .autosync, .fir]
        //.oldContactsBackup, - already beaing checked in this .contactsNoBackup
        //.syncComplete - .syncInProgress already checks it
        
        DispatchQueue.global().async {
            let semaphore = DispatchSemaphore(value: 0)
            var timeline: Timeline<WidgetBaseEntry>?
            
            //for now, only on entry is allowed
            for order in ordersCheckList {
                self.checkOrder(order: order) { preparedEntry in
                    debugPrint("!!! \(family) order prepared entry \(order)")
                    if let preparedEntry = preparedEntry {
                        self.save(entry: preparedEntry)
                        timeline = self.prepareTimeline(order: order, entry: preparedEntry)
                        debugPrint("!!! \(family) order prepared timeline \(order)")
                            
//                            if order == .syncInProgress, WidgetService.shared.syncStatus == .synced {
//
//                            } else {
//
//                            }
                            
                        if family == .systemSmall {
                            self.isTimelinePreparedSmall = true
                        } else {
                            self.isTimelinePreparedMedium = true
                        }
                        semaphore.signal()
                        
                    } else {
                        debugPrint("!!! \(family) order is nil \(order)")
                        semaphore.signal()
                    }
                }
                debugPrint("!!! \(family) order for entry \(order)")
                semaphore.wait()
                
                if let timeline = timeline {
                    timelineCallback(timeline)
                    return
                }
            }
        }
    }
    
    private func prepareTimeline(order: WidgetStateOrder, entry: WidgetBaseEntry) -> Timeline<WidgetBaseEntry> {
        switch order {
        case .login: //ORDER-0
            return Timeline(entries: [entry], policy: .never)
        case .quota, .freeUpSpace: //ORDER 1-2
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .hour, value: 8, to: currentDate) ?? currentDate
            return  Timeline(entries: [entry], policy: .after(refreshDate))
        case .syncInProgress://ORDER-3
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate
            return Timeline(entries: [entry], policy: .after(refreshDate))
        case .syncComplete:
            //a/dasdasd/asd/asd/asd
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .second, value: 5, to: currentDate) ?? currentDate
            return Timeline(entries: [entry], policy: .after(refreshDate))
        case .autosync, .contactsNoBackup, .oldContactsBackup, .fir: //ORDER-3-7
            return Timeline(entries: [entry], policy: .atEnd)
        }
    }
    
    private func save(entry: WidgetBaseEntry?) {
        if let entry = entry, WidgetPresentationService.shared.lastWidgetEntry?.state != entry.state {
            WidgetPresentationService.shared.notifyChangeWidgetState(entry.state)
        }
        
        WidgetPresentationService.shared.lastWidgetEntry = entry
    }
    
    private func checkOrder(order: WidgetStateOrder, entryCallback: @escaping WidgetBaseEntryCallback) {
        switch order {
        case .login:
            //ORDER-0
            checkLoginStatus(entryCallback: entryCallback)
        case .quota:
            //ORDER-1
            checkQuotaStatus(entryCallback: entryCallback)
        case .freeUpSpace:
            //ORDER-2
            checkStorageStatus(entryCallback: entryCallback)
        case .syncInProgress, .syncComplete:
            //ORDER-3
            //sync complete related to ORDER -3
            checkSyncInProgres(entryCallback: entryCallback)
        case .autosync:
            //ORDER-4
            checkSyncStatus(entryCallback: entryCallback)
        case .contactsNoBackup, .oldContactsBackup:
            //ORDER-5 (No contact backup):
            //ORDER-6 (Last backup is older than 1 month):
            checkContactBackupStatus(entryCallback: entryCallback)
        case .fir:
            //ORDER-7
            checkFIRStatus(entryCallback: entryCallback)
        }
        
    }
}

//MARK:- widget entry constraction
extension WidgetProvider {

    //ORDER-0
    ///Check if the user is login to the app or not. If the user is not login, display this widget: https://zpl.io/brwelx1
    private func checkLoginStatus(entryCallback: @escaping WidgetBaseEntryCallback) {
        WidgetPresentationService.shared.isAuthorized ? entryCallback(nil) : entryCallback(WidgetLoginRequiredEntry(date: Date()))
    }
    
    //ORDER-1
    ///Check user's lifebox storage quota.
    ///When a user's lifebox quota is (%75-%100) full, we will display this widget: https://zpl.io/VDyr45J
    private func checkQuotaStatus(entryCallback: @escaping WidgetBaseEntryCallback) {
        WidgetPresentationService.shared.getStorageQuota { usedPercentage in
            entryCallback(usedPercentage >= 75 ? WidgetQuotaEntry(usedPercentage: usedPercentage, date: Date()) : nil)
        }
    }
    
    //ORDER-2
    ///Check user's device storage.
    ///When a user's device storage is (%75-%100) full, we will display this widget: https://zpl.io/V4W4QZ4
    private func checkStorageStatus(entryCallback: @escaping WidgetBaseEntryCallback) {
        WidgetPresentationService.shared.getDeviceStorageQuota { usedPercentage in
            entryCallback(usedPercentage >= 75 ? WidgetDeviceQuotaEntry(usedPercentage: usedPercentage, date: Date()) : nil)
        }
    }
    
    //ORDER-3
    ///Check if any sync is in progress (manaul, auto, background, upload to lifebox via native share)
    ///Please write 1/x, 2/x on the widget and file name during syncing and display this widget:  https://zpl.io/VYOxGPn
    private func checkSyncInProgres(entryCallback: @escaping WidgetBaseEntryCallback) {
        guard
            WidgetPresentationService.shared.isPreperationFinished,
            WidgetPresentationService.shared.isPhotoLibriaryAvailable()
        else {
            entryCallback(nil)
            return
        }
        let syncInfo = WidgetPresentationService.shared.getSyncInfo()
        if syncInfo.syncStatus == .executing {
            //TODO: need file name
            entryCallback(WidgetSyncInProgressEntry(uploadCount: syncInfo.uploadCount,
                                                    totalCount: syncInfo.totalCount,
                                                    currentFileName: "name_of_file",
                                                    date: Date()))
            //TODO: should I  add another entry here for sync finisheD?
        } else {
            entryCallback(nil)
        }
        
    }
    
    //ORDER-4 (Checking unsynced files)
    ///Check if there are unsynced files in device gallery and auto sync value ON or OFF.
    private func checkSyncStatus(entryCallback: @escaping WidgetBaseEntryCallback) {
        guard
            WidgetPresentationService.shared.isPreperationFinished,
            WidgetPresentationService.shared.isPhotoLibriaryAvailable()
        else {
            entryCallback(nil)
            return
        }
        WidgetPresentationService.shared.hasUnsyncedItems { hasUnsynced in
            // unysnced items status enter
            let syncInfo = WidgetPresentationService.shared.getSyncInfo()
            if hasUnsynced {
                //TODO: need check syncStatus
                let isSyncEnabled = !syncInfo.syncStatus.isContained(in: [.failed, .undetermined, .stoped])
                if syncInfo.isAppLaunch && isSyncEnabled {
                    //this case for order 3 - sync in progress
                    entryCallback(nil)
                }
                
                entryCallback(WidgetAutoSyncEntry(isSyncEnabled: isSyncEnabled, date: Date()))
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
    private func checkContactBackupStatus(entryCallback: @escaping WidgetBaseEntryCallback) { //no cantact backup or last backup older > 1 month

        WidgetPresentationService.shared.getContactBackupStatus { response in
            guard let response = response else {
                entryCallback(nil)
                return
            }
            
            let todayDate = Date()
            guard let backupDate = response.date else {
                return entryCallback(WidgetContactBackupEntry(date: todayDate))
            }
            
            let components = Calendar.current.dateComponents([.month], from: backupDate, to: todayDate)
            if components.month! >= 1 {
                entryCallback(WidgetContactBackupEntry(backupDate: response.date, date: todayDate))
            } else {
                entryCallback(nil)
            }
        }
    }
    
    //ORDER-7 (Face Recognition):
    ///Check if user has AUTH_FACE_IMAGE_LOCATION authority with calling authority API and check if user's face-image recognition is enabled or not
    private func checkFIRStatus(entryCallback: @escaping WidgetBaseEntryCallback) {
        //TODO: isFIREnabled - check if being created correctly
        
        WidgetPresentationService.shared.getFIRStatus { response in
            let date: Date
            if response.isLoadingImages {
                date = Calendar.current.date(byAdding: .second, value: 10, to: Date())!
            } else {
                date = Calendar.current.date(byAdding: .second, value: 2, to: Date())!
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

