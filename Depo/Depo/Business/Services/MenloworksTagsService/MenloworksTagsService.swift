//
//  MenloworksTagsService.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

class MenloworksTagsService {
    
    private let reachabilityService = ReachabilityService()
    private init() { }
    
    static let shared = MenloworksTagsService()
    
    // MARK: - Event methods
    
    func onFirstLaunch() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "LifeboxLaunchedBefore")
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "LifeboxLaunchedBefore")
            let tag = MenloworksTags.Firstsession()
            hitTag(tag)
        }
    }
    
    func onTutorial() {
        let tag = MenloworksTags.Tutorial()
        hitTag(tag)
    }
    
    func onFileUploadedWithType(_ type: FileType) {
        var tag: MenloworksTag?
        
        switch type {
        case .image:
            tag = MenloworksTags.PhotoUpload(isWiFi: reachabilityService.isReachableViaWiFi)
        case .audio:
            tag = MenloworksTags.MusicUpload()
        case .video:
            tag = MenloworksTags.VideoUpload()
        case .allDocs, .unknown, .application:
            tag = MenloworksTags.FileUpload()
        default:
            break
        }
        
        if let tag = tag {
            hitTag(tag)
        }
    }
    
    func onLogin() {
        let tagWiFi3G = MenloworksTags.WiFi3G(isWiFi: reachabilityService.isReachableViaWiFi)
        hitTag(tagWiFi3G)
        
        let tagLogginCompleted = MenloworksTags.LogginCompleted()
        hitTag(tagLogginCompleted)
    }
    
    func onStartWithLogin(_ isLoggedIn: Bool) {
        let tag = MenloworksTags.LoggedIn(isLoggedIn: isLoggedIn)
        hitTag(tag)
        
        if isLoggedIn {
            sendInstagramImportStatus()
            sendFacebookImportStatus()
            sendFIRStatus()
        }
    }
    
    func onAllFilesOpen() {
        let tag = MenloworksTags.AllFilesOpen()
        hitTag(tag)
    }
    
    func onPhotosAndVideosOpen() {
        let tag = MenloworksTags.PhotosAndVideosOpen()
        hitTag(tag)
    }
    
    func onMusicOpen() {
        let tag = MenloworksTags.MusicOpen()
        hitTag(tag)
    }
    
    func onDocumentsOpen() {
        let tag = MenloworksTags.DocumentsOpen()
        hitTag(tag)
    }
    
    func onContactSyncPageOpen() {
        let tag = MenloworksTags.ContactSyncPageOpen()
        hitTag(tag)
    }
    
    func onCreateStoryPageOpen() {
        let tag = MenloworksTags.CreateStoryPageOpen()
        hitTag(tag)
    }
    
    func onPreferencesOpen() {
        let tag = MenloworksTags.PreferencesOpen()
        hitTag(tag)
    }
    
    func onPackagesOpen() {
        let tag = MenloworksTags.PackagesOpen()
        hitTag(tag)
    }
    
    func onAutosyncVideoViaWifi() {
        let tag = MenloworksTags.AutoSyncVideosViaWifi()
        hitTag(tag)
    }
    
    func onAutosyncVideoViaLte() {
        let tag = MenloworksTags.AutoSyncVideosViaLte()
        hitTag(tag)
    }
    
    func onAutosyncPhotosViaWifi() {
        let tag = MenloworksTags.AutoSyncPhotosViaWifi()
        hitTag(tag)
    }
    
    func onAutosyncPhotosViaLte() {
        let tag = MenloworksTags.AutoSyncPhotosViaLte()
        hitTag(tag)
    }
    
    func onSignUp() {
        let tag = MenloworksTags.SignUpCompleted()
        hitTag(tag)
    }
    
    func onContactUploaded() {
        let tag = MenloworksTags.ContactUploaded()
        hitTag(tag)
    }
    
    func onContactDownloaded() {
        let tag = MenloworksTags.ContactDownloaded()
        hitTag(tag)
    }
    
    func onEditClicked() {
        let tag = MenloworksTags.EditClicked()
        hitTag(tag)
    }
    
    func onStoryCreated() {
        let tag = MenloworksTags.StoryCreated()
        self.hitTag(tag)
    }
    
    func onVideoDisplayed() {
        let tag = MenloworksTags.VideoDisplayed()
        self.hitTag(tag)
    }
    
    func passcodeStatus(_ isEnabled: Bool) {
        let tag = MenloworksTags.PasscodeStatus(isEnabled: isEnabled)
        self.hitTag(tag)
    }
    
    func onRemoveFromAlbumClicked() {
        let tag = MenloworksTags.RemoveFromAlbumClicked()
        hitTag(tag)
    }
    
    func onPrintClicked() {
        let tag = MenloworksTags.PrintClicked()
        hitTag(tag)
    }
    
    func onSynchClicked() {
        let tag = MenloworksTags.SyncClicked()
        hitTag(tag)
    }
    
    func onDownloadClicked() {
        let tag = MenloworksTags.DownloadClicked()
        hitTag(tag)
    }
    
    func onDeleteClicked() {
        let tag = MenloworksTags.DeleteClicked()
        hitTag(tag)
    }
    
    func onShareClicked() {
        let tag = MenloworksTags.ShareClicked()
        hitTag(tag)
    }
    
    func onFavoritesOpen() {
        let tag = MenloworksTags.FavoritesOpen()
        hitTag(tag)
    }
    
    func onSearchOpen() {
        let tag = MenloworksTags.SearchOpen()
        hitTag(tag)
    }
    
    // MARK: - Accessory methods
    
    private func hitTag(_ tag: MenloworksTag) {
        if let value = tag.value {
            MPush.hitTag(tag.name, withValue: value)
        } else {
            MPush.hitTag(tag.name)
        }
    }
    
    private func sendInstagramImportStatus() {
        InstagramService().getSyncStatus(success: { (response) in
            guard let response = response as? SocialSyncStatusResponse,
                  let status = response.status else { return }
            let tag = MenloworksTags.InstagramImportStatus(isEnabled: status)
            self.hitTag(tag)
        }, fail: nil)
    }
    
    private func sendFacebookImportStatus() {
        FBService().requestStatus(success: { (response) in
            guard let response = response as? FBStatusObject,
                  let status = response.syncEnabled else { return }
            let tag = MenloworksTags.FacebookImportStatus(isEnabled: status)
            self.hitTag(tag)
        }, fail: nil)
    }
    
    private func sendFIRStatus() {
        AccountService().faceImageAllowed(success: { (response) in
            guard let response = response as? FaceImageAllowedResponse,
                  let status = response.allowed else { return }
            let tag = MenloworksTags.FaceImageRecognitionStatus(isEnabled: status)
            self.hitTag(tag)
        }, fail: { _ in })
    }
}
