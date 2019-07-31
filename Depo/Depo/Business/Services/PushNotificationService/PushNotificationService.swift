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
    
    private var notificationAction: PushNotificationAction?
    private var notificationActionURLString: String?
    
    //MARK: -
    
    func assignNotificationActionBy(launchOptions: [AnyHashable: Any]?) -> Bool {
        guard let actionString = launchOptions?["action"] as? String else {
            return false
        }

        notificationAction = PushNotificationAction(rawValue: actionString)
        
        if notificationAction == .http {
            notificationActionURLString = actionString
        }
        
        return notificationAction != nil
    }
    
    func assignDeepLink(innerLink: String?) -> Bool {
        guard let actionString = innerLink as String? else {
            return false
        }
        
        notificationAction = PushNotificationAction(rawValue: actionString)
        return notificationAction != nil
    }
    
    func openActionScreen() {
        guard var action = notificationAction else {
            return
        }
        
        if tokenStorage.accessToken == nil {
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
        case .http: openURL(notificationActionURLString)
        case .login: openLogin()
        case .search: openSearch()
        case .freeUpSpace: break
        case .settings: openSettings()
        case .profileEdit: openProfileEdit()
        case .changePassword: openChangePassword()
        case .photopickHistory: openPhotoPickHistory()
        case .myStorage: openMyStorage()
        case .becomePremium: openBecomePremium()
        }
        notificationAction = nil
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
    
    private func openTabBarItem(index: TabScreenIndex) {
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
                guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index.rawValue-1] else {
                    assertionFailure("This index is non existent 😵")
                    return
                }
                tabBarVC.tabBar.selectedItem = newSelectedItem
                tabBarVC.selectedIndex = index.rawValue
            case .photosScreenIndex:
                tabBarVC.showPhotosScreen(self)
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
        let isTurkcell = SingletonStorage.shared.accountInfo?.accountType == "TURKCELL"
        pushTo(router.passcodeSettings(isTurkcell: isTurkcell, inNeedOfMail: false))
    }
    
    private func openLoginSettings() {
        if SingletonStorage.shared.accountInfo?.accountType == "TURKCELL" {
            pushTo(router.turkcellSecurity)            
        }
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
}
