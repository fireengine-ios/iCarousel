//
//  MenloworksEventsService.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class MenloworksEventsService {

    private init() { }
    
    static let shared = MenloworksEventsService()
    
    // MARK: - Event methods
    
    func onFirstLaunch() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "LifeboxLaunchedBeforeEvent")
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "LifeboxLaunchedBeforeEvent")
            MPush.hitEvent(MenloworksEventsConstants.firstsession)
        }
    }
    
    func onLaunch() {
        MPush.hitEvent(MenloworksEventsConstants.newsession)
    }
    
    func onSignUp() {
        MPush.hitEvent(MenloworksEventsConstants.signupCompleted)
    }
    
    func onLogin() {
        MPush.hitEvent(MenloworksEventsConstants.loggedinCompleted)
    }
    
    func onFirstAutosyncOff() {
        MPush.hitEvent(MenloworksEventsConstants.firstAutosyncOFF)
    }
    
    func onAutosyncOff() {
        MPush.hitEvent(MenloworksEventsConstants.autosyncOFF)
    }
    
    func onAllFilesOpen() {
        MPush.hitEvent(MenloworksEventsConstants.allFilesOpen)
    }
    
    func onPhotosAndVideosOpen() {
        MPush.hitEvent(MenloworksEventsConstants.photosAndVideosOpen)
    }
    
    func onMusicOpen() {
        MPush.hitEvent(MenloworksEventsConstants.musicOpen)
    }
    
    func onDocumentsOpen() {
        MPush.hitEvent(MenloworksEventsConstants.documentsOpen)
    }
    
    func onContactSyncPageOpen() {
        MPush.hitEvent(MenloworksEventsConstants.contactSyncPageOpen)
    }
    
    func onContactDownloaded() {
        MPush.hitEvent(MenloworksEventsConstants.contactDownloaded)
    }
    
    func onContactUploaded() {
        MPush.hitEvent(MenloworksEventsConstants.contactUploaded)
    }
    
    func onFavoritesOpen() {
        MPush.hitEvent(MenloworksEventsConstants.favoritesOpen)
    }
    
    func onStoryPageOpen() {
        MPush.hitEvent(MenloworksEventsConstants.storyPageOpen)
    }
    
    func onStoryCreated() {
        MPush.hitEvent(MenloworksEventsConstants.storyCreated)
    }
    
    func onPackagesOpen() {
        MPush.hitEvent(MenloworksEventsConstants.packagesOpen)
    }
    
    func onPreferencesOpen() {
        MPush.hitEvent(MenloworksEventsConstants.preferencesOpen)
    }
    
    func onSubscriptionClicked(_ type: MenloworksSubscriptionStorage) {
        switch type {
        case .fiftyGB:
            MPush.hitEvent(MenloworksEventsConstants.fiftyGBClicked)
        case .fiveHundredGB:
            MPush.hitEvent(MenloworksEventsConstants.fiveHundredGBClicked)
        case .twoThousandFiveHundredGB:
            MPush.hitEvent(MenloworksEventsConstants.twoThousandFiveHundredGBClicked)
        }
    }
    
    func onSubscriptionPurchaseCompleted(_ type: MenloworksSubscriptionProductID) {
        switch type {
        case .fiftyGbID:
            MPush.hitEvent(MenloworksEventsConstants.fiftyGBPurchasedStatus)
        case .fiveHundredGbID:
            MPush.hitEvent(MenloworksEventsConstants.fiveHundredGBPurchasedStatus)
        case .twoThousandFiveHundredGbID:
            MPush.hitEvent(MenloworksEventsConstants.twoThousandFiveHundredGBPurchasedStatus)
        }
    }
    
    func onFileDeleted() {
        MPush.hitEvent(MenloworksEventsConstants.fileDeleted)
    }
    
    func onPromocodeActivated() {
        MPush.hitEvent(MenloworksEventsConstants.promocodeActivated)
    }
    
    func onSocialMediaPageOpen() {
        MPush.hitEvent(MenloworksEventsConstants.socialMediaPageOpen)
    }
    
    func onInstagramConnected() {
        MPush.hitEvent(MenloworksEventsConstants.instagramConnected)
    }
    
    func onFacebookConnected() {
        MPush.hitEvent(MenloworksEventsConstants.facebookConnected)
    }
    
    func onLoggedOut() {
        MPush.hitEvent(MenloworksEventsConstants.loggedOut)
    }
    
    func onFaceImageRecognitionOn() {
        MPush.hitEvent(MenloworksEventsConstants.faceImageRecognitionOn)
    }
    
    func onFaceImageRecognitionOff() {
        MPush.hitEvent(MenloworksEventsConstants.faceImageRecognitionOff)
    }
    
    func onPasscodeSet() {
        MPush.hitEvent(MenloworksEventsConstants.passcodeSet)
    }
    
    func onTouchIDSet() {
        MPush.hitEvent(MenloworksEventsConstants.touchIDSet)
    }
    
    func onTurkcellPasswordSet() {
        MPush.hitEvent(MenloworksEventsConstants.turkcellPasswordSet)
    }
    
    func onAutoLoginSet() {
        MPush.hitEvent(MenloworksEventsConstants.autoLoginSet)
    }
    
    func onRemoveFromAlbumClicked() {
        MPush.hitEvent(MenloworksEventsConstants.removeFromAlbumClicked)
    }
    
    func onPrintClicked() {
        MPush.hitEvent(MenloworksEventsConstants.cellographClicked)
    }
    
    func onSyncClicked() {
        MPush.hitEvent(MenloworksEventsConstants.syncClicked)
    }
    
    func onDownloadClicked() {
        MPush.hitEvent(MenloworksEventsConstants.downloadClicked)
    }
    
    func onDeleteClicked() {
        MPush.hitEvent(MenloworksEventsConstants.deleteClicked)
    }
    
    func onShareClicked() {
        MPush.hitEvent(MenloworksEventsConstants.shareClicked)
    }
    
    func onAddToFavoritesClicked() {
        MPush.hitEvent(MenloworksEventsConstants.addToFavoritesClicked)
    }
    
    func onApporveEulaPageClicked() {
        MPush.hitEvent(MenloworksEventsConstants.apporvedEulaPage)
    }
    
    func onEmailChanged() {
        MPush.hitEvent(MenloworksEventsConstants.emailChanged)
    }
    
    func onFacebookTransfered() {
        MPush.hitEvent(MenloworksEventsConstants.facebookTransfered)
    }
    
    func onInstagramTransfered() {
        MPush.hitEvent(MenloworksEventsConstants.instagramTransfered)
    }
    
    func onDropboxTransfered() {
        MPush.hitEvent(MenloworksEventsConstants.dropboxTransfered)
    }
    
    func onDeviceStorageExceeded80PercStatus() {
        MPush.hitEvent(MenloworksEventsConstants.deviceStorageExceeded80Perc)
    }
    
    func onDeviceStorageExceeded90PercStatus() {
        MPush.hitEvent(MenloworksEventsConstants.deviceStorageExceeded90Perc)
    }
    
    func onQuotaExceeded80PercStatus() {
        MPush.hitEvent(MenloworksEventsConstants.quotaExceeded80PercStatus)
    }
    
    func onQuotaExceeded90PercStatus() {
        MPush.hitEvent(MenloworksEventsConstants.quotaExceeded90PercStatus)
    }
    
    func onQuotaFullStatus() {
        MPush.hitEvent(MenloworksEventsConstants.quotaFullStatus)
    }
    
    func onFiftyGBPurchasedStatus() {
        MPush.hitEvent(MenloworksEventsConstants.fiftyGBPurchasedStatus)
    }
    
    func onFiveHundredGBPurchasedStatus() {
        MPush.hitEvent(MenloworksEventsConstants.fiveHundredGBPurchasedStatus)
    }
    
    func onTwoThousandFiveHundredGBPurchasedStatus() {
        MPush.hitEvent(MenloworksEventsConstants.twoThousandFiveHundredGBPurchasedStatus)
    }
}
