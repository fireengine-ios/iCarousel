//
//  MenloworksAppEvents.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

enum MenloworksSubscriptionStorage: String {
    case fiftyGB = "50 GB"
    case fiveHundredGB = "500 GB"
    case twoThousandFiveHundredGB = "2.5 TB"
}

//TODO: Implement IAP ID
enum MenloworksSubscriptionProductID: String {
    case fiftyGbID = "50 GB"
    case fiveHundredGbID = "500 GB"
    case twoThousandFiveHundredGbID = "2.5 TB"
}

class MenloworksAppEvents {
    static func onAppLaunch() {
        MenloworksTagsService.shared.onFirstLaunch()
        
        MenloworksEventsService.shared.onFirstLaunch()
        MenloworksEventsService.shared.onLaunch()
        
        onDiskStorageStatus()
        
        sendProfileName()
    }
    
    static func sendProfileName() {
        SingletonStorage.shared.getAccountInfoForUser(forceReload: true, success: { response in
            guard let name = response.name else {
                return
            }
            let nameIsEmpty = name.isEmpty
            MenloworksTagsService.shared.onProfileNameChanged(isEmpty: nameIsEmpty)
            MenloworksEventsService.shared.profileName(isEmpty: nameIsEmpty)
            /// we don't need error handling here
        }, fail: {_ in })
    }
    
    static func onDiskStorageStatus() {
        let busyDiskSpaceInPercent = 1 - Device.getFreeDiskSpaceInPercent
        if busyDiskSpaceInPercent >= 0.9 {
            MenloworksEventsService.shared.onDeviceStorageExceeded90PercStatus()
        } else if busyDiskSpaceInPercent >= 0.8 {
            MenloworksEventsService.shared.onDeviceStorageExceeded80PercStatus()
        }
    }
    
    static func onTutorial() {
        MenloworksTagsService.shared.onTutorial()
    }
    
    static func onFileUploadedWithType(_ type: FileType, isAutosync: Bool) {
        MenloworksTagsService.shared.onFileUploadedWithType(type, isAutoSync: isAutosync)
    }
    
    static func onLogin() {
        MenloworksTagsService.shared.onLogin()
        MenloworksEventsService.shared.onLogin()
    }
    
    static func onStartWithLogin(_ isLoggedIn: Bool) {
        MenloworksTagsService.shared.onStartWithLogin(isLoggedIn)
        
        if isLoggedIn {
            onQuotaInfo()
        }
    }
    
     static func onQuotaInfo() {
        AccountService().quotaInfo(success: { response in
            guard let quotoInfo = response as? QuotaInfoResponse,
                let quotaBytes = quotoInfo.bytes,
                let usedBytes = quotoInfo.bytesUsed
            else { return }
            
            let quotaBytesConverted = Double(quotaBytes)
            let usedBytesConverted = Double(usedBytes)
            
            guard quotaBytesConverted != 0 else {
                return
            }
            
            let busyStorage = usedBytesConverted / quotaBytesConverted
            
            MenloworksTagsService.shared.onQuotaStatus(percentageValue: Int(busyStorage * 100))
            
            if busyStorage > 0.99 {
                MenloworksEventsService.shared.onQuotaFullStatus()
                
            }
            
            if busyStorage > 0.9 {
                MenloworksEventsService.shared.onQuotaExceeded90PercStatus()
            } else if busyStorage > 0.8 {
                MenloworksEventsService.shared.onQuotaExceeded80PercStatus()
            }
            

            }, fail: { _ in })
    }
    
    static func onSignUp() {
        MenloworksTagsService.shared.onSignUp()
        MenloworksEventsService.shared.onSignUp()
    }
    
    static func onRemoveFromAlbumClicked() {
        MenloworksTagsService.shared.onRemoveFromAlbumClicked()
        MenloworksEventsService.shared.onRemoveFromAlbumClicked()
    }
    
    static func onFacebookConnected() {
        MenloworksTagsService.shared.onFacebookConnected()
        MenloworksEventsService.shared.onFacebookConnected()
    }
    
    static func onInstagramConnected() {
        MenloworksTagsService.shared.onInstagramConnected()
        MenloworksEventsService.shared.onInstagramConnected()
    }
    
    static func onPromocodeActivated() {
        MenloworksTagsService.shared.onPromocodeActivated()
        MenloworksEventsService.shared.onPromocodeActivated()
    }
    
    static func onFileDeleted() {
        MenloworksTagsService.shared.onFileDeleted()
        MenloworksEventsService.shared.onFileDeleted()
    }
    
    static func onAllFilesOpen() {
        MenloworksTagsService.shared.onAllFilesOpen()
        MenloworksEventsService.shared.onAllFilesOpen()
    }
    
    static func onPhotosAndVideosOpen() {
        MenloworksTagsService.shared.onPhotosAndVideosOpen()
        MenloworksEventsService.shared.onPhotosAndVideosOpen()
    }
    
    static func onMusicOpen() {
        MenloworksTagsService.shared.onMusicOpen()
        MenloworksEventsService.shared.onMusicOpen()
    }
    
    static func onDocumentsOpen() {
        MenloworksTagsService.shared.onDocumentsOpen()
        MenloworksEventsService.shared.onDocumentsOpen()
    }
    
    static func onContactSyncPageOpen() {
        MenloworksTagsService.shared.onContactSyncPageOpen()
        MenloworksEventsService.shared.onContactSyncPageOpen()
    }
    
    static func onContactDownloaded() {
        MenloworksTagsService.shared.onContactDownloaded()
        MenloworksEventsService.shared.onContactDownloaded()
    }
    
    static func onContactUploaded() {
        MenloworksTagsService.shared.onContactUploaded()
        MenloworksEventsService.shared.onContactUploaded()
    }
    
    static func onFavoritesOpen() {
        MenloworksEventsService.shared.onFavoritesOpen()
    }
    
    static func onStoryCreated() {
        MenloworksTagsService.shared.onStoryCreated()
        MenloworksEventsService.shared.onStoryCreated()
    }
    
    static func onCreateStoryPageOpen() {
        MenloworksTagsService.shared.onCreateStoryPageOpen()
        MenloworksEventsService.shared.onStoryPageOpen()
    }
    
    static func onPackagesOpen() {
        MenloworksTagsService.shared.onPackagesOpen()
        MenloworksEventsService.shared.onPackagesOpen()
    }
    
    static func onPreferencesOpen() {
        MenloworksTagsService.shared.onPreferencesOpen()
        MenloworksEventsService.shared.onPreferencesOpen()
    }
    
    static func onSubscriptionClicked(_ type: MenloworksSubscriptionStorage) {
        MenloworksTagsService.shared.onSubscriptionClicked(type)
        MenloworksEventsService.shared.onSubscriptionClicked(type)
    }
    
    static func onSubscriptionPurchaseCompleted(_ type: MenloworksSubscriptionProductID) {
        MenloworksTagsService.shared.onSubscriptionPurchaseCompleted(type)
        MenloworksEventsService.shared.onSubscriptionPurchaseCompleted(type)
    }
    
    static func onPrintClicked() {
        MenloworksTagsService.shared.onPrintClicked()
        MenloworksEventsService.shared.onPrintClicked()
    }
    
    static func onSyncClicked() {
        MenloworksTagsService.shared.onSyncClicked()
        MenloworksEventsService.shared.onSyncClicked()
    }
    
    static func onDownloadClicked() {
        MenloworksTagsService.shared.onDownloadClicked()
        MenloworksEventsService.shared.onDownloadClicked()
    }
    
    static func onDeleteClicked() {
        MenloworksTagsService.shared.onDeleteClicked()
        MenloworksEventsService.shared.onDeleteClicked()
    }
    
    static func onShareClicked() {
        MenloworksTagsService.shared.onShareClicked()
        MenloworksEventsService.shared.onShareClicked()
    }
}
