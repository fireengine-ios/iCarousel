//
//  Notifications.swift
//  Depo
//
//  Created by Andrei Novikau on 22.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

extension NSNotification.Name {
    static let hidePlusTabBar = Notification.Name(rawValue: "HideMainTabBarPlusNotification")
    static let showPlusTabBar = Notification.Name(rawValue: "ShowMainTabBarPlusNotification")
    static let musicDrop = Notification.Name(rawValue: "MusicDrop")
    static let photosScreen = Notification.Name(rawValue: "PhotosScreenOn")
    static let videoScreen = Notification.Name(rawValue: "VideoScreenOn")
    static let updateThreeDots = Notification.Name(rawValue: "UpdateThreeDots")
}
