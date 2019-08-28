//
//  MenloworksEventsService.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import XPush

//FIXME: Menloworks should be added to the AnalyticsService
class MenloworksEventsService {

    private init() { }
    
    static let shared = MenloworksEventsService()
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    
    // MARK: - Event methods
    
    private func mergedHit(event: String) {
        XPush.hitEvent(event)
    }
    
    func onFirstLaunch() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "LifeboxLaunchedBeforeEvent")
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "LifeboxLaunchedBeforeEvent")
            mergedHit(event: MenloworksEventsConstants.firstsession)
        }
    }
    
    func onLaunch() {
        mergedHit(event: MenloworksEventsConstants.newsession)
    }
    
    func onSignUp() {
        mergedHit(event: MenloworksEventsConstants.signupCompleted)
    }
    
    func onLogin() {
        onPasscodeSet()
        mergedHit(event: MenloworksEventsConstants.loggedinCompleted)
    }
    
    func onFirstAutosyncOff() {
        mergedHit(event: MenloworksEventsConstants.firstAutosyncOFF)
    }
    
    func onAutosyncOff() {
        mergedHit(event: MenloworksEventsConstants.autosyncOFF)
    }
    
    func onAllFilesOpen() {
        mergedHit(event: MenloworksEventsConstants.allFilesOpen)
    }
    
    func onPhotosAndVideosOpen() {
        mergedHit(event: MenloworksEventsConstants.photosAndVideosOpen)
    }
    
    func onMusicOpen() {
        mergedHit(event: MenloworksEventsConstants.musicOpen)
    }
    
    func onDocumentsOpen() {
        mergedHit(event: MenloworksEventsConstants.documentsOpen)
    }
    
    func onContactSyncPageOpen() {
        mergedHit(event: MenloworksEventsConstants.contactSyncPageOpen)
    }
    
    func onContactDownloaded() {
        mergedHit(event: MenloworksEventsConstants.contactDownloaded)
    }
    
    func onContactUploaded() {
        mergedHit(event: MenloworksEventsConstants.contactUploaded)
    }
    
    func onFavoritesOpen() {
        mergedHit(event: MenloworksEventsConstants.favoritesOpen)
    }
    
    func onStoryPageOpen() {
        mergedHit(event: MenloworksEventsConstants.storyPageOpen)
    }
    
    func onStoryCreated() {
        mergedHit(event: MenloworksEventsConstants.storyCreated)
    }
    
    func onPackagesOpen() {
        mergedHit(event: MenloworksEventsConstants.packagesOpen)
    }
    
    func onPreferencesOpen() {
        mergedHit(event: MenloworksEventsConstants.preferencesOpen)
    }
    
    func onSubscriptionClicked(_ type: MenloworksSubscriptionStorage) {
        switch type {
        case .fiftyGB:
            mergedHit(event: MenloworksEventsConstants.fiftyGBClicked)
        case .fiveHundredGB:
            mergedHit(event: MenloworksEventsConstants.fiveHundredGBClicked)
        case .twoThousandFiveHundredGB:
            mergedHit(event: MenloworksEventsConstants.twoThousandFiveHundredGBClicked)
        }
    }
    
    func onSubscriptionPurchaseCompleted(_ type: MenloworksSubscriptionProductID) {
        switch type {
        case .fiftyGbID:
            mergedHit(event: MenloworksEventsConstants.fiftyGBPurchasedStatus)
        case .fiveHundredGbID:
            mergedHit(event: MenloworksEventsConstants.fiveHundredGBPurchasedStatus)
        case .twoThousandFiveHundredGbID:
            mergedHit(event: MenloworksEventsConstants.twoThousandFiveHundredGBPurchasedStatus)
        }
    }
    
    func onFileDeleted() {
        mergedHit(event: MenloworksEventsConstants.fileDeleted)
    }
    
    func onPromocodeActivated() {
        mergedHit(event: MenloworksEventsConstants.promocodeActivated)
    }
    
    func onSocialMediaPageOpen() {
        mergedHit(event: MenloworksEventsConstants.socialMediaPageOpen)
    }
    
    func onInstagramConnected() {
        mergedHit(event: MenloworksEventsConstants.instagramConnected)
    }
    
    func onFacebookConnected() {
        mergedHit(event: MenloworksEventsConstants.facebookConnected)
    }
    
    func onLoggedOut() {
        mergedHit(event: MenloworksEventsConstants.loggedOut)
    }
    
    func onFaceImageRecognitionOn() {
        mergedHit(event: MenloworksEventsConstants.faceImageRecognitionOn)
    }
    
    func onFaceImageRecognitionOff() {
        mergedHit(event: MenloworksEventsConstants.faceImageRecognitionOff)
    }
    
    func onPasscodeSet() {
        mergedHit(event: MenloworksEventsConstants.passcodeSet)
    }
    
    func onTouchIDSet() {
        mergedHit(event: MenloworksEventsConstants.touchIDSet)
    }
    
    func onTurkcellPasswordSet() {
        mergedHit(event: MenloworksEventsConstants.turkcellPasswordSet)
    }
    
    func onAutoLoginSet() {
        mergedHit(event: MenloworksEventsConstants.autoLoginSet)
    }
    
    func onRemoveFromAlbumClicked() {
        mergedHit(event: MenloworksEventsConstants.removeFromAlbumClicked)
    }
    
    func onPrintClicked() {
        mergedHit(event: MenloworksEventsConstants.cellographClicked)
    }
    
    func onSyncClicked() {
        mergedHit(event: MenloworksEventsConstants.syncClicked)
    }
    
    func onDownloadClicked() {
        mergedHit(event: MenloworksEventsConstants.downloadClicked)
    }
    
    func onDeleteClicked() {
        mergedHit(event: MenloworksEventsConstants.deleteClicked)
    }
    
    func onShareClicked() {
        mergedHit(event: MenloworksEventsConstants.shareClicked)
    }
    
    func onAddToFavoritesClicked() {
        mergedHit(event: MenloworksEventsConstants.addToFavoritesClicked)
    }
    
    func onApporveEulaPageClicked() {
        mergedHit(event: MenloworksEventsConstants.apporvedEulaPage)
    }
    
    func onEmailChanged() {
        mergedHit(event: MenloworksEventsConstants.emailChanged)
    }
    
    func onFacebookTransfered() {
        mergedHit(event: MenloworksEventsConstants.facebookTransfered)
    }
    
    func onInstagramTransfered() {
        mergedHit(event: MenloworksEventsConstants.instagramTransfered)
    }
    
    func onDropboxTransfered() {
        mergedHit(event: MenloworksEventsConstants.dropboxTransfered)
    }
    
    func onDeviceStorageExceeded80PercStatus() {
        mergedHit(event: MenloworksEventsConstants.deviceStorageExceeded80Perc)
    }
    
    func onDeviceStorageExceeded90PercStatus() {
        mergedHit(event: MenloworksEventsConstants.deviceStorageExceeded90Perc)
    }
    
    func onQuotaExceeded80PercStatus() {
        mergedHit(event: MenloworksEventsConstants.quotaExceeded80PercStatus)
    }
    
    func onQuotaExceeded90PercStatus() {
        mergedHit(event: MenloworksEventsConstants.quotaExceeded90PercStatus)
    }
    
    func onQuotaFullStatus() {
        mergedHit(event: MenloworksEventsConstants.quotaFullStatus)
    }
    
    func onFiftyGBPurchasedStatus() {
        mergedHit(event: MenloworksEventsConstants.fiftyGBPurchasedStatus)
    }
    
    func onFiveHundredGBPurchasedStatus() {
        mergedHit(event: MenloworksEventsConstants.fiveHundredGBPurchasedStatus)
    }
    
    func onTwoThousandFiveHundredGBPurchasedStatus() {
        mergedHit(event: MenloworksEventsConstants.twoThousandFiveHundredGBPurchasedStatus)
    }
    
    func onDownloadItem(with type: String, success: Bool) {
        let eventName = String(format: MenloworksEventsConstants.downloadedItemFormat, type)
    }
    
    func onShareItem(with type: FileType, toApp: String) {
        let itemType = (type == .image) ? "Photo" : "Video"
        let eventName = String(format: MenloworksEventsConstants.sharedItemFormat, itemType, toApp)
    }
    
    func profileName(isEmpty: Bool) {
        if isEmpty {
            mergedHit(event: MenloworksEventsConstants.profileNameEmpty)
        } else {
            mergedHit(event: MenloworksEventsConstants.profileNameFull)
        }
    }
    
    func onBackgroundSync() {
        mergedHit(event: MenloworksEventsConstants.backgroundSync)
    }
}
