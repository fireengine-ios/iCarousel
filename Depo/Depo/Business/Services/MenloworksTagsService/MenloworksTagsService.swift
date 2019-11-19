//
//  MenloworksTagsService.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 2/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//
import XPush
class MenloworksTagsService {
    
    private let reachabilityService = ReachabilityService.shared
    private init() { }
    
    static let shared = MenloworksTagsService()
    private lazy var passcodeStorage: PasscodeStorage = factory.resolve()
    private lazy var defaults = UserDefaults(suiteName: SharedConstants.groupIdentifier)
    
    private lazy var campaignService = CampaignServiceImpl()
    private lazy var instapickService: InstapickService = factory.resolve()
    
    // MARK: - Event methods
    
    func onFirstLaunch() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "LifeboxLaunchedBeforeTag")
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "LifeboxLaunchedBeforeTag")
            let tag = MenloworksTags.Firstsession()
            hitTag(tag)
        }
    }
    
    func onTutorial() {
        let tag = MenloworksTags.Tutorial()
        hitTag(tag)
    }
    
    func onFileUploadedWithType(_ type: FileType, isAutoSync: Bool) {
        DispatchQueue.toMain {
            var tag: MenloworksTag?
            
            ///must be in the main queue
            let notInBackground = UIApplication.shared.applicationState == .active
            
            switch type {
            case .image:
                let isWifi = self.reachabilityService.isReachableViaWiFi
                if notInBackground {
                    if isAutoSync {
                        tag = MenloworksTags.PhotoUploadAutosync(isWiFi: isWifi)
                    } else {
                        tag = MenloworksTags.PhotoUploadManual(isWiFi: isWifi)
                    }
                } else {
                    tag = MenloworksTags.PhotoUploadBackground(isWiFi: isWifi)
                }
            case .audio:
                tag = MenloworksTags.MusicUpload()
            case .video:
                let isWifi = self.reachabilityService.isReachableViaWiFi
                if notInBackground {
                    if isAutoSync {
                        tag = MenloworksTags.VideoUploadAutosync(isWiFi: isWifi)
                    } else {
                        tag = MenloworksTags.VideoUploadManual(isWiFi: isWifi)
                    }
                } else {
                    tag = MenloworksTags.VideoUploadBackground(isWiFi: isWifi)
                }
            case .allDocs, .unknown, .application:
                tag = MenloworksTags.FileUpload()
            default:
                break
            }
            
            if let tag = tag {
                self.hitTag(tag)
            }
        }
    }
    
    func onSubscriptionClicked(_ type: MenloworksSubscriptionStorage) {
        var tag: MenloworksTag?
        
        switch type {
        case .fiftyGB:
            tag = MenloworksTags.FiftyGBClicked()
        case .fiveHundredGB:
            tag = MenloworksTags.FiveHundredGBClicked()
        case .twoThousandFiveHundredGB:
            tag = MenloworksTags.TwoThousandFiveHundredGBClicked()
        }
        
        if let tag = tag {
            hitTag(tag)
        }
    }
    func onSubscriptionPurchaseCompleted(_ type: MenloworksSubscriptionProductID) {
        var tag: MenloworksTag?
        
        switch type {
        case .fiftyGbID:
            tag = MenloworksTags.FiftyGBPurchasedStatus()
        case .fiveHundredGbID:
            tag = MenloworksTags.FiveHundredGBPurchasedStatus()
        case .twoThousandFiveHundredGbID:
            tag = MenloworksTags.TwoThousandFiveHundredGBPurchasedStatus()
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
        
        guard factory.resolve().accessToken != nil else {
            return
        }
        
        if isLoggedIn {
            checkTurkcellSecuritySettings()
            sendInstagramImportStatus()
            sendFacebookImportStatus()
            sendFIRStatus()
            sendSubscriptionsStatus()
            sendPhotopickLeftAnalysisStatus(nil)
            sendCampaignPhotopickStatus()
        }
        if let isEnabled = defaults?.object(forKey: "isEnabledKey") as? Bool {
            onTouchIDSettingsChanged(isEnabled)
        }
//        onTouchIDSettingsChanged(((defaults?.object(forKey: "isEnabledKey")) != nil))
        
        passcodeStatus(!passcodeStorage.isEmpty)
    }
    
    func checkTurkcellSecuritySettings() {
        AccountService().securitySettingsInfo(success: { [weak self] response in
            guard let unwrapedSecurityresponse = response as? SecuritySettingsInfoResponse,
                let turkCellPasswordOn = unwrapedSecurityresponse.turkcellPasswordAuthEnabled,
                let turkCellAutoLogin = unwrapedSecurityresponse.mobileNetworkAuthEnabled else {
                    return
            }
            
            DispatchQueue.main.async {
                self?.onTurkcellPasswordSettingsChanged(turkCellPasswordOn)
                self?.onAutoLoginSettingsChanged(turkCellAutoLogin)
            }
            
        }) { [weak self] error in
            debugLog("Error from Turkcell Security: \(error)")
        }
    }
    
    func onNotificationPermissionChanged(_ isEnabled: Bool) {
        guard !UserDefaults.standard.bool(forKey: "onNotificationPermissionChanged") else { return }
        
        UserDefaults.standard.set(true, forKey: "onNotificationPermissionChanged")
        
        let tag = MenloworksTags.NotificationPermissionStatus(isEnabled: isEnabled)
        hitTag(tag)
    }
    
    func onGalleryPermissionChanged(_ isEnabled: Bool) {
        let tag = MenloworksTags.GalleryPermissionStatus(isEnabled: isEnabled)
        hitTag(tag)
    }
    
    func onLocationPermissionChanged(_ authorization: String) {
        let tag = MenloworksTags.LocationPermissionStatus(authorization: authorization)
        hitTag(tag)
    }
    
    func onPeriodicContactSync(_ periodicContactSync: String) {
        let tag = MenloworksTags.PeriodicContactSync(periodicContactSync: periodicContactSync)
        hitTag(tag)
    }
    
    func onTouchIDSettingsChanged(_ isEnabled: Bool) {
        let tag = MenloworksTags.TouchIDStatus(isEnabled: isEnabled)
        hitTag(tag)
    }

    func onAutoLoginSettingsChanged(_ isEnabled: Bool) {
        let tag = MenloworksTags.AutoLoginChanged(isEnabled: isEnabled)
        hitTag(tag)
    }
    
    func onTurkcellPasswordSettingsChanged(_ isEnabled: Bool) {
        let tag = MenloworksTags.TurkcellPasswordChanged(isEnabled: isEnabled)
        hitTag(tag)
    }
    
    func onPromocodeActivated() {
        let tag = MenloworksTags.PromocodeActivated()
        hitTag(tag)
    }
    
    func onFacebookConnected() {
        let tag = MenloworksTags.FacebookConnected()
        hitTag(tag)
    }
    
    func onInstagramConnected() {
        let tag = MenloworksTags.InstagramConnected()
        hitTag(tag)
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
    
    func onAutosyncVideosOff() {
        let tag = MenloworksTags.AutoSyncVideosOff()
        hitTag(tag)
    }
    
    func onAutosyncPhotosOff() {
        let tag = MenloworksTags.AutoSyncPhotosOff()
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
    
    func onFirstAutosyncVideoViaWifi() {
        let tag = MenloworksTags.FirstAutoSyncVideosViaWifi()
        hitTag(tag)
    }
    
    func onFirstAutosyncVideoViaLte() {
        let tag = MenloworksTags.FirstAutoSyncVideosViaLte()
        hitTag(tag)
    }
    
    func onFirstAutosyncVideoOff() {
        let tag = MenloworksTags.FirstAutoSyncVideosOff()
        hitTag(tag)
    }
    
    func onFirstAutosyncPhotosViaWifi() {
        let tag = MenloworksTags.FirstAutoSyncPhotosViaWifi()
        hitTag(tag)
    }
    
    func onFirstAutosyncPhotosViaLte() {
        let tag = MenloworksTags.FirstAutoSyncPhotosViaLte()
        hitTag(tag)
    }
    
    func onFirstAutosyncPhotoOff() {
        let tag = MenloworksTags.FirstAutoSyncPhotosOff()
        hitTag(tag)
    }
    
    func onAutoSyncOff() {
        let tag = MenloworksTags.AutoSyncOff()
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
    
    func onSyncClicked() {
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
    
    func onFileDeleted() {
        let tag = MenloworksTags.FileDeleted()
        hitTag(tag)
    }
    
    func onQuotaStatus(percentageValue: Int) {
        let tag = MenloworksTags.QuotaStatus(percentageValue: percentageValue)
        hitTag(tag)
    }
    
    func onAutosyncStatus(isOn: Bool) {
        let tag = MenloworksTags.AutosyncStatus(isOn: isOn)
        hitTag(tag)
    }
    
    func onFirstAutoSyncOff() {
        let tag = MenloworksTags.AutosyncFirstOff()
        hitTag(tag)
        
    }
    
    func onAutosyncPhotosStatusOff() {
        XPush.hitTag(MenloworksTags.NameConstants.autosyncPhotosStatus, withValue: MenloworksTags.ValueConstants.off)
    }
    
    func onAutosyncPhotosStatusOn(isWifi: Bool) {
        let tag = MenloworksTags.AutosyncPhotosStatus(isWifi: isWifi)
        hitTag(tag)
    }
    
    func onAutosyncVideosStatusOff() {
        XPush.hitTag(MenloworksTags.NameConstants.autosyncVideosStatus, withValue: MenloworksTags.ValueConstants.off)
    }
    
    func onAutosyncVideosStatusOn(isWifi: Bool) {
        let tag = MenloworksTags.AutosyncVideosStatus(isWifi: isWifi)
        hitTag(tag)
    }
    
    func onFiftyGBPurchasedStatus() {
        let tag = MenloworksTags.FiftyGBPurchasedStatus()
        hitTag(tag)
    }
    
    func onFiveHundredGBPurchasedStatus() {
        let tag = MenloworksTags.FiveHundredGBPurchasedStatus()
        hitTag(tag)
    }
    
    func onTwoThousandFiveHundredGBPurchasedStatus() {
        let tag = MenloworksTags.TwoThousandFiveHundredGBPurchasedStatus()
        hitTag(tag)
    }
    
    func onFavoritesPageClicked() {
        let tag = MenloworksTags.FavoritesPageClicked()
        hitTag(tag)
    }
    
    func onSocialMediaPageClicked() {
        let tag = MenloworksTags.SocialMediaPageClicked()
        hitTag(tag)
    }
    
    func editedPhotoSaved() {
        let tag = MenloworksTags.EditedPhotoSaved()
        hitTag(tag)
    }
    
    func faceImageRecognition(isOn: Bool) {
        let tag = MenloworksTags.FaceImageRecognitionStatus(isEnabled: isOn)
        hitTag(tag)
    }
    
    func instagramImport(isOn: Bool) {
        let tag = MenloworksTags.InstagramImportStatus(isEnabled: isOn)
        self.hitTag(tag)
    }
    
    func facebookImport(isOn: Bool) {
        let tag = MenloworksTags.FacebookImportStatus(isEnabled: isOn)
        self.hitTag(tag)
    }
    
    func sendPhotopickLeftAnalysisStatus(_ status: InstapickAnalyzesCount?) {
        func trackStatus(_ status: InstapickAnalyzesCount) {
            let tag = MenloworksTags.PhotopickLeftAnalysis(isFree: status.isFree, value: status.left)
            hitTag(tag)
        }
        
        if let status = status {
            trackStatus(status)
            return
        }
        
        instapickService.getAnalyzesCount { response in
            switch response {
            case .success(let status):
                trackStatus(status)
            case .failed(let error):
                debugLog("sendPhotopickLeftAnalysisStatus failed \(error.description)")
            }
        }
    }
    
    func sendPhotopickAnalyzeStatus(isSuccess: Bool) {
        hitTag(MenloworksTags.PhotopickAnalyzeResult(isSuccess: isSuccess))
        hitTag(MenloworksTags.PhotopickAnalyze(isSuccess: isSuccess))
    }
    
    func sendCampaignPhotopickStatus() {
        // These tags will only be sent for Turkish users
        guard SingletonStorage.shared.isUserFromTurkey else {
            return
        }
        
        campaignService.getPhotopickDetails { result in
            switch result {
            case .success(let status):
                // These tags will only be sent between startDate and launchDate
                if (status.startDate...status.launchDate).contains(Date()) {
                    let dailyRemainingTag = MenloworksTags.PhotopickDailyDrawLeft(value: status.dailyRemaining)
                    self.hitTag(dailyRemainingTag)
                    
                    let totalUsedTag = MenloworksTags.PhotopickTotalDraw(value: status.totalUsed)
                    self.hitTag(totalUsedTag)
                }
            case .failure(let error):
                debugLog("sendCampaignPhotopickStatus failed \(error.description)")
            }
        }
    }
    
    // MARK: - Accessory methods
    
    private func hitTag(_ tag: MenloworksTag) {
        if let value = tag.value {
            XPush.hitTag(tag.name, withValue: value)
        } else {
            XPush.hitTag(tag.name)
        }
    }
    
    private func sendInstagramImportStatus() {
        InstagramService().getSyncStatus(success: { response in
            guard let response = response as? SocialSyncStatusResponse,
                  let status = response.status else { return }
            let tag = MenloworksTags.InstagramImportStatus(isEnabled: status)
            self.hitTag(tag)
        }, fail: nil)
    }
    
    private func sendFacebookImportStatus() {
        FBService().requestStatus(success: { response in
            guard let response = response as? FBStatusObject,
                  let status = response.syncEnabled else { return }
            let tag = MenloworksTags.FacebookImportStatus(isEnabled: status)
            self.hitTag(tag)
        }, fail: nil)
    }
    
    private func sendFIRStatus() {
        AccountService().faceImageAllowed(success: { response in
            guard let response = response as? SettingsInfoPermissionsResponse,
                  let status = response.isFaceImageAllowed else {
                    return
            }
            let tag = MenloworksTags.FaceImageRecognitionStatus(isEnabled: status)
            self.hitTag(tag)
        }, fail: { _ in })
    }
    
    private func sendSubscriptionsStatus() {
        SubscriptionsServiceIml().activeSubscriptions(success: { response in
            guard let subscriptionsResponse = response as? ActiveSubscriptionResponse else { return }
            
            let list = subscriptionsResponse.list.sorted(by: { sub1, sub2 -> Bool in
                guard let sub1Quota = sub1.subscriptionPlanQuota,
                    let sub2Quota = sub2.subscriptionPlanQuota else {
                        return true
                }
                return sub1Quota < sub2Quota
            })
            
            let subLength = list.count
            
            for subscription in list {
                if subscription.subscriptionPlanCometOfferId == "581814" {
                    let tag = MenloworksTags.PlatinUserStatus()
                    self.hitTag(tag)
                }
            }
            
            for i in 0...4 {
                let packageName = String(format: "%@%d", MenloworksTags.UserPackageStatus().name, i + 1)
                var displayName = MenloworksTags.NoUserPackageStatus().name
                
                if i < subLength {
                    let subscription = list[i]
                    displayName = subscription.subscriptionPlanDisplayName ?? ""
                }
                
                XPush.hitTag(packageName, withValue: displayName)
            }
        }) { _ in }
    }
    
    func onProfileNameChanged(isEmpty: Bool) {        
        let profileNameChangedTag = MenloworksTags.ProfileName(isEmpty: isEmpty)
        hitTag(profileNameChangedTag)
        
        let profileNameIsEmptyTag: MenloworksTag
        
        if isEmpty {
            profileNameIsEmptyTag = MenloworksTags.ProfileNameEmpty()
        } else {
            profileNameIsEmptyTag = MenloworksTags.ProfileNameFull()
        }
        
        hitTag(profileNameIsEmptyTag)
    }
}
