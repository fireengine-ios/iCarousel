//
//  PushNotificationService.swift
//  Depo
//
//  Created by Andrei Novikau on 27.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

final class PushNotificationService {
    
    private init() { }
    
    static let shared = PushNotificationService()
    
    private lazy var router = RouterVC()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var storageVars: StorageVars = factory.resolve()
    private lazy var analyticsService: AnalyticsService = factory.resolve()

    private var notificationAction: PushNotificationAction?
    private var notificationParameters: String?
    
    //MARK: -
    
    func assignNotificationActionBy(launchOptions: [AnyHashable: Any]?) -> Bool {
        let action = launchOptions?[PushNotificationParameter.action.rawValue] as? String ?? launchOptions?[PushNotificationParameter.pushType.rawValue] as? String
        
        guard let actionString = action else {
            return false
        }
        
        guard let notificationAction = PushNotificationAction(rawValue: actionString) else {
            assertionFailure("unowned push type")
            debugLog("PushNotificationService received notification with unowned type \(String(describing: action))")
            return false
        }
        
        debugLog("PushNotificationService received notification with type \(actionString)")
        parse(options: launchOptions, action: notificationAction)
        return true
    }
    
    func assignDeepLink(innerLink: String?, options: [AnyHashable: Any]?) -> Bool {
        guard let actionString = innerLink as String? else {
            return false
        }
                
        guard let notificationAction = PushNotificationAction(rawValue: actionString) else {
            //assertionFailure("unowned push type")
            debugLog("PushNotificationService received deepLink with unowned type \(String(describing: actionString))")
            return false
        }
        
        debugLog("PushNotificationService received deepLink with type \(actionString)")
        parse(options: options, action: notificationAction)
        return true
    }
    
    func assignUniversalLink(url: URL) -> Bool {
        guard let path = url.absoluteString.components(separatedBy: "#!/").last, let action = UniversalLinkPath(rawValue: path)?.action else {
            return false
        }
        debugLog("PushNotificationService received universal link with type \(action.rawValue)")
        parse(options: nil, action: action)
        return true
    }
    
    private func parse(options: [AnyHashable: Any]?, action: PushNotificationAction) {
        self.notificationAction = action
        
        switch notificationAction {
        case .http?:
            notificationParameters = action.rawValue
        case .tbmatic?:
            notificationParameters = options?[PushNotificationParameter.tbmaticUuids.rawValue] as? String
        default:
            break
        }
        
        storageVars.deepLink = action.rawValue
        storageVars.deepLinkParameters = options
    }
    
    func openActionScreen() {
        guard var action = notificationAction else {
            return
        }
        
        trackIfNeeded(action: action)
        
        let isLoggedIn = tokenStorage.accessToken != nil
        if !isLoggedIn && !action.isContained(in: [.supportFormLogin, .supportFormSignup]) {
            action = .login
        }
        
        if isLoggedIn && action.isContained(in: [.login, .widgetLogout]) {
            clear()
            return
        }
                
        switch action {
        case .main, .home: openMain()
        case .syncSettings, .widgetAutoSyncDisabled: openSyncSettings()
        case .floatingMenu: openFloatingMenu()
        case .packages, .widgetQuota: openPackages()
        case .photos, .widgetSyncInProgress, .widgetUnsyncedFiles, .widgetFIRLess3People, .widgetFIRStandart: openPhotos()
        case .videos: openVideos()
        case .albums: openAlbums()
        case .stories: openStories()
        case .allFiles: openAllFiles()
        case .music: openMusic()
        case .documents: openDocuments()
        case .contactSync, .widgetNoBackup, .widgetOldBackup: openContactSync()
        case .periodicContactSync: openPeriodicContactSync()
        case .favorites: openFavorites()
        case .createStory: openCreateStory()
        case .contactUs: openContactUs()
        case .usageInfo: openUsageInfo()
        case .autoUpload: openAutoUpload()
        case .recentActivities: openRecentActivities()
        case .email: openEmail()
        case .importDropbox: openImportDropbox()
        case .socialMedia: openSocialMedia()
        case .faq: openFaq()
        case .passcode: openPasscode()
        case .loginSettings: openLoginSettings()
        case .faceImageRecognition, .widgetFIRDisabled: openFaceImageRecognition()
        case .people, .widgetFIR: openPeople()
        case .things: openThings()
        case .places: openPlaces()
        case .http: openURL(notificationParameters)
        case .login, .widgetLogout:
            openLogin()
            clear()
        case .search: openSearch()
        case .freeUpSpace, .widgetFreeUpSpace:
            if FreeAppSpace.session.state == .finished && CacheManager.shared.isCacheActualized {
                openFreeUpSpace()
            } else {
                openMain()
            }
        case .settings: openSettings()
        case .profileEdit: openProfileEdit()
        case .changePassword: openChangePassword()
        case .photopickHistory: openPhotoPickHistory()
        case .myStorage: openMyStorage()
        case .becomePremium: openBecomePremium()
        case .tbmatic: openTBMaticPhotos(notificationParameters)
        case .securityQuestion: openSecurityQuestion()
        case .permissions: openPermissions()
        case .photopickCampaignDetail: openCampaignDetails()
        case .supportFormSignup, .supportFormLogin:
            if isLoggedIn {
                openContactUs()
            } else { 
                openSupport(type: action == .supportFormSignup ? .signup : .login)
            }
        case .trashBin:
            openTrashBin()
        case .hiddenBin: openHiddenBin()
        case .sharedWithMe: openSharedWithMe()
        case .sharedByMe: openShareByMe()
        case .invitation : openInvitation()
        case .chatbot: openChatbot()
        case .verifyEmail: openVerifyEmail()
        case .verifyRecoveryEmail: openVerifyRecoveryEmail()
        case .silent: break
        }
        
        
        if router.tabBarController != nil {
            clear()
        }
    }
    
    private func clear() {
        // clear if user haven't access or need screen is showed
        // no clean for cold application start - screen showing from home page
        notificationAction = nil
        notificationParameters = nil
        storageVars.deepLink = nil
        storageVars.deepLinkParameters = nil
    }
    
    //MARK: -
    
    private func pushTo(_ controller: UIViewController?) {
        guard let controller = controller else {
            return
        }
        
        DispatchQueue.main.async {
            if let navigationController = self.router.topNavigationController {
                if navigationController.presentedViewController != nil {
                    self.router.pushOnPresentedView(viewController: controller)
                } else if !(controller is SegmentedController), let existController = navigationController.viewControllers.first(where: { type(of: $0) == type(of: controller) }) {
                    //TODO: add check child segments and refresh data protocol for update pages
                    if existController == navigationController.viewControllers.last {
                        return
                    }
                    navigationController.popToViewController(existController, animated: false)
                } else {
                    self.router.pushViewController(viewController: controller)
                }
            } else {
                self.router.pushViewController(viewController: controller)
            }
        }
    }
    
    private func openTabBarItem(index: TabScreenIndex, segmentIndex: Int? = nil) {
        guard let tabBarVC = UIApplication.topController() as? TabBarViewController else {
            return
        }
        
        if tabBarVC.selectedIndex != index.rawValue {
            switch index {
            case .home:
                guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index.rawValue] else {
                    assertionFailure("This index is non existent 😵")
                    return
                }
                tabBarVC.tabBar.selectedItem = newSelectedItem
                tabBarVC.selectedIndex = index.rawValue
            case .contactsSync, .documents://because their index is more then two. And we have one offset for button selection but when we point to array index we need - 1 for those items where index > 2.
                guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index.rawValue] else {
                    assertionFailure("This index is non existent 😵")
                    return
                }
                tabBarVC.tabBar.selectedItem = newSelectedItem
                tabBarVC.selectedIndex = index.rawValue - 1
            
                if let segmentIndex = segmentIndex, let segmentedController = tabBarVC.currentViewController as? SegmentedController  {
                    segmentedController.loadViewIfNeeded()
                    segmentedController.switchSegment(to: segmentIndex)
                }
                
            case .gallery:
                tabBarVC.showPhotoScreen()
            }
        } else {
            tabBarVC.popToRootCurrentNavigationController(animated: true)
        }
    }
    
    //MARK: - Actions
    
    private func openLogin() {
        if let navigationController = router.topNavigationController, navigationController.viewControllers.contains(where: { $0 is RegistrationViewController }) {
            return
        }
        
        pushTo(router.loginScreen)
    }
    
    private func openMain() {
        openTabBarItem(index: .home)
    }
    
    private func openSyncSettings() {
        pushTo(router.autoUpload)
    }
    
    private func openFloatingMenu() {
        guard let tabBarVC = UIApplication.topController() as? TabBarViewController else {
            return
        }
        
        tabBarVC.showRainbowIfNeed()
    }
    
    private func openPackages() {
        let campaignId = storageVars.value(forDeepLinkParameter: .campaign) as? String
        let viewController = router.packages(campaignId: campaignId)
        pushTo(viewController)
    }
    
    private func openPhotos() {
        openTabBarItem(index: .gallery)
    }
    
    private func openVideos() {
//        openTabBarItem(index: .videosScreenIndex)
    }
    
    private func openAlbums() {
        pushTo(router.albumsListController())
    }
    
    private func openStories() {
        pushTo(router.storiesListController())
    }
    
    private func openAllFiles() {
        openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.allFiles.rawValue)
    }
    
    private func openDocuments() {
        openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.documents.rawValue)
    }
    
    private func openMusic() {
        openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.music.rawValue)
    }
    
    private func openFavorites() {
        openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.favorites.rawValue)
    }

    private func openTrashBin() {
        openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.trashBin.rawValue)
    }
    
    private func openContactSync() {
        openTabBarItem(index: .contactsSync)
    }
    
    private func openPeriodicContactSync() {
        pushTo(router.periodicContactsSync)
    }
    
    private func openCreateStory() {
        let controller = router.createStory(navTitle: TextConstants.createStory)
        router.pushViewController(viewController: controller)
    }
    
    private func openContactUs() {
        router.showFeedbackSubView()
    }
    
    private func openUsageInfo() {
        pushTo(router.usageInfo)
    }
    
    private func openAutoUpload() {
        pushTo(router.autoUpload)
    }
    
    private func openRecentActivities() {
        pushTo(router.vcActivityTimeline)
    }
    
    private func openEmail() {
        if let userInfo = SingletonStorage.shared.accountInfo {
            pushTo(router.userProfile(userInfo: userInfo))
        }
    }
    
    private func openImportDropbox() {
        pushTo(router.connectedAccounts)
    }
    
    private func openSocialMedia() {
        pushTo(router.connectedAccounts)
    }
    
    private func openFaq() {
        pushTo(router.helpAndSupport)
    }
    
    private func openPasscode() {
        let isTurkcellAccount = SingletonStorage.shared.accountInfo?.accountType == "TURKCELL"
        pushTo(router.passcodeSettings(isTurkcell: isTurkcellAccount, inNeedOfMail: false))
    }
    
    private func openLoginSettings() {
        let isTurkcell = SingletonStorage.shared.accountInfo?.accountType == AccountType.turkcell.rawValue
        let controller = router.turkcellSecurity(isTurkcell: isTurkcell)
        pushTo(controller)
    }
    
    private func openFaceImageRecognition() {
        pushTo(router.faceImage)
    }
    
    private func openPeople() {
        pushTo(router.peopleListController())
    }
    
    private func openThings() {
        pushTo(router.thingsListController())
    }
    
    private func openPlaces() {
        pushTo(router.placesListController())
    }
    
    private func openSearch() {
        let output = router.getViewControllerForPresent()
        let controller = router.searchView(navigationController: output?.navigationController, output: output as? SearchModuleOutput)
        pushTo(controller)
    }
    
    private func openFreeUpSpace() {
        pushTo(router.freeAppSpace())
    }
    
    private func openURL(_ path: String?) {
        guard let path = path, let url = URL(string: path) else {
            return
        }
        
        UIApplication.shared.openSafely(url)
    }
    
    private func openSettings() {
        pushTo(router.settings)
    }
    
    private func openProfileEdit() {
        SingletonStorage.shared.getAccountInfoForUser(forceReload: false, success: { [weak self] response in
            let vc = self?.router.userProfile(userInfo: response)
            self?.pushTo(vc)
            /// we don't need error handling here
        }, fail: {_ in})
        
    }
    
    private func openChangePassword() {
        pushTo(router.changePassword)
    }
    
    private func openPhotoPickHistory() {
        pushTo(router.analyzesHistoryController())
    }
    
    private func openMyStorage() {
        pushTo(router.myStorage(usageStorage: nil))
    }
    
    private func openBecomePremium() {
        pushTo(router.premium())
    }
    
    private func openTBMaticPhotos(_ uuidsByString: String?) {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .tbmatik, eventLabel: .tbmatik(.notification))
        
        debugLog("PushNotificationService try to open TBMatic screen")
        // handle list of uuids with two variants for separators "," and ", "
        guard let uuids = uuidsByString?.replacingOccurrences(of: " ", with: "").components(separatedBy: ",") else {
            assertionFailure()
            debugLog("PushNotificationService uuids is empty")
            return
        }
        
        // check for cold start from push - present on home page
        guard router.tabBarController != nil else {
            return
        }
        
        let controller = router.tbmaticPhotosContoller(uuids: uuids)
        DispatchQueue.main.async {
            self.router.presentViewController(controller: controller)
        }
    }
    
    private func openSecurityQuestion() {
        debugLog("PushNotificationService try to open Security Question screen")

        let controller = SetSecurityQuestionViewController.initFromNib()
        pushTo(controller)
    }
    
    private func openPermissions() {
        debugLog("PushNotificationService try to open Permission screen")

        let controller = router.permissions
        pushTo(controller)
    }
    
    private func openCampaignDetails() {
        let controller = router.campaignDetailViewController()
        pushTo(controller)
    }
    
    private func openSupport(type: SupportFormScreenType) {
        let controller = SupportFormController.with(screenType: type)
        pushTo(controller)
    }
    
    private func openHiddenBin() {
        let controller = router.hiddenPhotosViewController()
        pushTo(controller)
    }
    
    private func trackIfNeeded(action: PushNotificationAction) {
        guard action.fromWidget else {
            return
        }
        
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .openWithWidget, eventLabel: .success)
    }
    
    private func openSharedWithMe() {
        openSharedController(type: .withMe)
    }
    
    private func openShareByMe() {
        openSharedController(type: .byMe)
    }

    private func openInvitation() {
        pushTo(router.invitation)
    }

    private func openChatbot() {
        if Device.locale == "tr" || Device.locale == "en" {
            #if LIFEBOX
            FirebaseRemoteConfig.shared.fetchChatbotMenuEnable { [weak self] in
                if $0 {
                    self?.pushTo(self?.router.chatbot)
                }
            }
            #endif
        }
    }

    private func openVerifyEmail() {
        if let userInfo = SingletonStorage.shared.accountInfo {
            let profile = router.userProfile(userInfo: userInfo, appearAction: .presentVerifyEmail)
            pushTo(profile)
        }
    }

    private func openVerifyRecoveryEmail() {
        if let userInfo = SingletonStorage.shared.accountInfo {
            let profile = router.userProfile(userInfo: userInfo, appearAction: .presentVerifyRecoveryEmail)
            pushTo(profile)
        }
    }
    
    private func openSharedController(type: PrivateShareType) {
        guard let controller = router.sharedFiles as? SegmentedController,
              let index = controller.viewControllers.firstIndex(where: { ($0 as? PrivateShareSharedFilesViewController)?.shareType == type }) else {
            return
        }
        controller.loadViewIfNeeded()
        controller.switchSegment(to: index)
        pushTo(controller)
    }
}
