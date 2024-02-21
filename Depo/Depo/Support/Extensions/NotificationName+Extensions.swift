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
    public static let localAlbumStatusDidChange = Notification.Name("localAlbumStatusDidChange")
    public static let deinitPlayer = Notification.Name("deinitPlayer")
    public static let reusePlayer = Notification.Name("reusePlayer")
    public static let foryouGetUpdateData = Notification.Name("foryouGetUpdateData")
    public static let freeAppSpaceToBackScreen = Notification.Name("freeAppSpaceToBackScreen")
    public static let createOnlyOfficeDocumentsReloadData = Notification.Name("createOnlyOfficeDocumentsReloadData")
    public static let setProfilePhoto = Notification.Name("setProfilePhoto")
    public static let startUpdateProfileFlow = Notification.Name("startUpdateProfileFlow")
    public static let isProcecessPrepairing = Notification.Name("isProcecessPrepairing")
}
