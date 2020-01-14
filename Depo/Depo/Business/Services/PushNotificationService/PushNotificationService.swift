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
            assertionFailure("unowned push type")
            debugLog("PushNotificationService received deepLink with unowned type \(String(describing: actionString))")
            return false
        }
        
        debugLog("PushNotificationService received deepLink with type \(actionString)")
        parse(options: options, action: notificationAction)
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
        
        let isLoggedIn = tokenStorage.accessToken != nil
        if !isLoggedIn && !action.isContained(in: [.supportFormLogin, .supportFormSignup]) {
            action = .login
        }
                
        switch action {
        case .main, .home: openMain()
        case .syncSettings: openSyncSettings()
        case .floatingMenu: openFloatingMenu()
        case .packages: openPackages()
        case .photos: openPhotos()
        case .videos: openVideos()
        case .albums: openAlbums()
        case .stories: openStories()
        case .allFiles: openAllFiles()
        case .music: openMusic()
        case .documents: openDocuments()
        case .contactSync: openContactSync()
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
        case .faceImageRecognition: openFaceImageRecognition()
        case .people: openPeople()
        case .things: openThings()
        case .places: openPlaces()
        case .http: openURL(notificationParameters)
        case .login:
            openLogin()
            clear()
        case .search: openSearch()
        case .freeUpSpace: break
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
            openTabBarItem(index: .documentsScreenIndex, segmentIndex: DocumentsScreenSegmentIndex.trashBin.rawValue)
        case .hiddenBin: openHiddenBin()
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
            if self.router.navigationController?.presentedViewController != nil {
                self.router.pushOnPresentedView(viewController: controller)
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
            case .homePageScreenIndex:
                guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index.rawValue] else {
                    assertionFailure("This index is non existent 😵")
                    return
                }
                tabBarVC.tabBar.selectedItem = newSelectedItem
                tabBarVC.selectedIndex = index.rawValue
            case .contactsSyncScreenIndex, .documentsScreenIndex://because their index is more then two. And we have one offset for button selection but when we point to array index we need - 1 for those items where index > 2.
                guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index.rawValue] else {
                    assertionFailure("This index is non existent 😵")
                    return
                }
                tabBarVC.tabBar.selectedItem = newSelectedItem
                tabBarVC.selectedIndex = index.rawValue - 1
            
                guard let segmentIndex = segmentIndex else {
                    return
                }
                
                if let segmentedController = tabBarVC.currentViewController as? SegmentedController {
                    segmentedController.loadViewIfNeeded()
                    segmentedController.switchSegment(to: segmentIndex)
                }
                
            case .photosScreenIndex:
                tabBarVC.showPhotoScreen()
            }
        }
    }
    
    //MARK: - Actions
    
    private func openLogin() {
        pushTo(router.loginScreen)
    }
    
    private func openMain() {
        openTabBarItem(index: .homePageScreenIndex)
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
        pushTo(router.packages)
    }
    
    private func openPhotos() {
        openTabBarItem(index: .photosScreenIndex)
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
        pushTo(router.allFiles(moduleOutput: nil, sortType: .AlphaBetricAZ, viewType: .List))
    }
    
    private func openMusic() {
        pushTo(router.musics)
    }
    
    private func openDocuments() {
        openTabBarItem(index: .documentsScreenIndex)
    }
    
    private func openContactSync() {
        openTabBarItem(index: .contactsSyncScreenIndex)
    }
    
    private func openPeriodicContactSync() {
        pushTo(router.periodicContactsSync)
    }
    
    private func openFavorites() {
        pushTo(router.favorites(moduleOutput: nil, sortType: .AlphaBetricAZ, viewType: .List))
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
        pushTo(router.premium(title: TextConstants.lifeboxPremium, headerTitle: TextConstants.becomePremiumMember))
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
}
