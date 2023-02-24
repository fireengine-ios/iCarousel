//
//  NotificationViewOutput.swift
//  Depo
//
//  Created by yilmaz edis on 9.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

protocol NotificationViewOutput {
    func viewIsReady()
    func viewWillAppear()
    
    func notificationsCount() -> Int
    func getNotification(at index: Int) -> NotificationServiceResponse
    func deleteNotification(at index: Int)
    func deleteAllNotification(at indicesToRemove: [Int])
    func deleteAllNotification()
    func getNotifications(at indexs: [Int]) -> [NotificationServiceResponse]
    
    func delete(with rows: [Int])
    func read(with id: String)
    
    var onlyRead: Bool { get set }
    var onlyShowAlerts: Bool { get set }
}
