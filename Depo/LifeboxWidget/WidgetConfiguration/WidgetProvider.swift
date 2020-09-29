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

struct WidgetProvider: TimelineProvider {
    typealias Entry = WidgetBaseEntry
    private static let timeStep = 2

    func placeholder(in context: Context) -> Self.Entry {
        if let entry = WidgetPresentationService.shared.lastWidgetEntry {
            return entry
        }
        return WidgetDeviceQuotaEntry(usedPercentage: 67, date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (Self.Entry) -> Void) {
        if let entry = WidgetPresentationService.shared.lastWidgetEntry {
            completion(entry)
            return
        }
        
        getTimeline(in: context) { timeline in
            if let entry = timeline.entries.first {
                completion(entry)
            } else {
                completion(WidgetQuotaEntry(usedPercentage: 90, date: Date()))
            }
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Self.Entry>) -> Void) {
        let currentDate = Date()
        var mainEntries: [WidgetBaseEntry] = []
        if WidgetPresentationService.shared.isAuthorized {
            refreshEntries { entries in
                mainEntries.append(contentsOf: entries)
                //let time = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
                let timeline = Timeline(entries: mainEntries, policy: .atEnd)
                save(entry: mainEntries.last)
                completion(timeline)
            }
        } else {
            mainEntries.append(WidgetLoginRequiredEntry(date: currentDate))
            let timeline = Timeline(entries: mainEntries, policy: .never)
            save(entry: mainEntries.last)
            completion(timeline)
        }
    }
    
    private func save(entry: WidgetBaseEntry?) {
        WidgetPresentationService.shared.lastWidgetEntry = entry
    }
    
    private func refreshEntries(completion: @escaping (([WidgetBaseEntry]) -> ())) {
        let todayDate = Date()
        
        var entries: [WidgetBaseEntry] = []
        var timeInterval = 2
        
        let group = DispatchGroup()
        // unysnced items status enter
        group.enter()
        // user life capacity enter
        group.enter()
        // user device capactity enter
        group.enter()
        // user contact backup enter
        group.enter()
        // user premium status enter
        group.enter()

        group.notify(queue: .main) {
            completion(entries)
        }
        
        // unysnced items status enter
        WidgetPresentationService.shared.hasUnsyncedItems { hasUnsynced in
            let syncInfo = WidgetPresentationService.shared.getSyncInfo()
            if syncInfo.syncStatus == .executing {
                //TODO: need file name
                entries.append(WidgetSyncInProgressEntry(uploadCount: syncInfo.uploadCount,
                                                         totalCount: syncInfo.totalCount,
                                                         currentFileName: "name_of_file",
                                                         date: todayDate))
            } else if hasUnsynced {
                //TODO: need check syncStatus
                let isSyncEnabled = !syncInfo.syncStatus.isContained(in: [.failed, .undetermined, .stoped])
                entries.append(WidgetAutoSyncEntry(isSyncEnabled: isSyncEnabled,
                                                   isAppLaunched: syncInfo.isAppLaunch,
                                                   date: todayDate))
            }
            
            group.leave()
        }

        // user life capacity
        WidgetPresentationService.shared.getStorageQuota(
            completion: { usedPersentage in
                if usedPersentage >= 75 {
                    entries.append(WidgetQuotaEntry(usedPercentage: usedPersentage, date: todayDate))
                }
                group.leave()
            },
            fail: { group.leave() })

        // user device capactity
        WidgetPresentationService.shared.getDeviceStorageQuota { usedPersentage in
            if usedPersentage >= 75 {
                let date = Calendar.current.date(byAdding: .minute, value: timeInterval, to: todayDate)!
                entries.append(WidgetDeviceQuotaEntry(usedPercentage: usedPersentage, date: date))
                timeInterval += Self.timeStep
            }
            group.leave()
        }

        // user contact backup
        WidgetPresentationService.shared.getContactBackupStatus(
            completion: { response in
                if let lastBackupDate = response.date {
                    let components = Calendar.current.dateComponents([.month], from: lastBackupDate, to: todayDate)
                    let date = Calendar.current.date(byAdding: .minute, value: timeInterval, to: todayDate)!
                    if components.month! >= 1 && response.totalNumberOfContacts <= .zero {
                        entries.append(WidgetContactBackupEntry(backupDate: lastBackupDate,
                                                    date: date))
                        timeInterval += Self.timeStep
                    } else if response.totalNumberOfContacts <= .zero {
                        entries.append(WidgetContactBackupEntry(date: date))
                        timeInterval += Self.timeStep
                    }
                }
                group.leave()
            },
            fail: { group.leave() })

        // premium users
        WidgetPresentationService.shared.getFIRStatus { response in
            let date: Date
            if response.isLoadingImages {
                date = Calendar.current.date(byAdding: .second, value: 10, to: todayDate)!
            } else {
                date = Calendar.current.date(byAdding: .second, value: timeInterval, to: todayDate)!
            }

            let entry = WidgetUserInfoEntry(
                isFIREnabled: response.userInfo.isFIREnabled,
                hasFIRPermission: response.userInfo.hasFIRPermission,
                peopleInfos: response.userInfo.peopleInfos,
                date: date
            )
            entries.append(entry)
            timeInterval += Self.timeStep
            group.leave()
        }
    }
}
