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

    func placeholder(in context: Context) -> WidgetBaseEntry {
        WidgetQuotaEntry(usedPercentage: 40, date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetBaseEntry) -> Void) {
        completion(WidgetQuotaEntry(usedPercentage: 40, date: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetBaseEntry>) -> Void) {
        let currentDate = Date()
        var mainEntries: [WidgetBaseEntry] = []
        if WidgetPresentationService.shared.isAuthorized {
            refreshEntries { entries in
                mainEntries.append(contentsOf: entries)
                let time = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
                let timeline = Timeline(entries: mainEntries, policy: .after(time))
                completion(timeline)
            }
        } else {
            mainEntries.append(WidgetLoginRequiredEntry(date: currentDate))
            let timeline = Timeline(entries: mainEntries, policy: .never)
            completion(timeline)
        }
    }
    
    private func refreshEntries(completion: @escaping (([WidgetBaseEntry]) -> ())){
        let todayDate = Date()
        
        var entries: [WidgetBaseEntry] = []
        var timeInterval = 2
        
        let group = DispatchGroup()
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

        // user life capacity
        WidgetPresentationService.shared.getStorageQuota(
            completion: { usedPersentage in
                if usedPersentage > 75 {
                    entries.append(WidgetQuotaEntry(usedPercentage: usedPersentage, date: todayDate))
                }
                group.leave()
            },
            fail: { group.leave() })

        // user device capactity
        WidgetPresentationService.shared.getDeviceStorageQuota { usedPersentage in
            if usedPersentage > 75 {
                let date = Calendar.current.date(byAdding: .minute, value: timeInterval, to: todayDate)!
                entries.append(WidgetDeviceQuotaEntry(usedPersentage: usedPersentage, date: date))
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
                    if response.totalNumberOfContacts <= .zero {
                        entries.append(WidgetContactBackupEntry(date: date))
                        timeInterval += Self.timeStep
                    } else if components.month! >= 1 {
                        entries.append(WidgetContactBackupEntry(backupDate: lastBackupDate,
                                                    date: date))
                        timeInterval += Self.timeStep
                    }
                }
                group.leave()
            },
            fail: { group.leave() })
        
        // premium users
        WidgetPresentationService.shared.getPremiumStatus { response in
            let date = Calendar.current.date(byAdding: .minute, value: timeInterval, to: todayDate)!
            let entry = WidgetUserInfoEntry(
                isFIREnabled: response.isFIREnabled,
                isPremiumUser: response.isPremiumUser,
                date: date
            )
            entries.append(entry)
            timeInterval += Self.timeStep
            group.leave()
        }
    }
}
