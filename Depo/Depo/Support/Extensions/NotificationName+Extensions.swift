//
//  NotificationName+Extensions.swift
//  Depo
//
//  Created by Konstantin on 5/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


extension Notification.Name {
    public static let changeFaceImageStatus = Notification.Name("changeFaceImageStatus")
    public static let allLocalMediaItemsHaveBeenLoaded = Notification.Name("allLocalMediaItemsHaveBeenLoaded")
    public static let autoSyncStatusDidChange = Notification.Name("autoSyncStatusDidChange")
    public static let apiReachabilityDidChange = Notification.Name("apiReachabilityDidChange")
    public static let notificationPhotoLibraryDidChange = Notification.Name("notificationPhotoLibraryDidChange")
    public static let reachabilityChanged = Notification.Name("reachabilityChanged")
}
