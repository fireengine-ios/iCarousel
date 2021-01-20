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
        
        if isLoggedIn && action.isContained(in: [.login]) {
            clear()
            return
        }
                
        switch action {
        case .main, .home: openMain()
        case .floatingMenu: openFloatingMenu()
        case .myDisk: openMyDisk()
        case .music: openMusic()
        case .documents: openDocuments()
        case .favorites: openFavorites()
        case .contactUs: openContactUs()
        case .usageInfo: openUsageInfo()
        case .recentActivities: openRecentActivities()
        case .email: openEmail()
        case .faq: openFaq()
        case .passcode: openPasscode()
        case .http: openURL(notificationParameters)
        case .login:
            openLogin()
            clear()
        case .search: openSearch()
        case .settings: openSettings()
        case .profileEdit: openProfileEdit()
        case .changePassword: openChangePassword()
        case .securityQuestion: openSecurityQuestion()
        case .permissions: openPermissions()
        case .supportFormSignup, .supportFormLogin:
            if isLoggedIn {
                openContactUs()
            } else { 
                openSupport(type: action == .supportFormSignup ? .signup : .login)
            }
        case .trashBin:
            openTrashBin()
        case .sharedWithMe: openSharedWithMe()
        case .sharedByMe: openShareByMe()
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
    
    func openTabBarItem(index: TabScreenIndex, segmentIndex: Int? = nil) {
        guard let tabBarVC = UIApplication.topController() as? TabBarViewController else {
            return
        }

        if tabBarVC.selectedIndex != index.rawValue {
            switch index {
            case .documents:
                guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index.rawValue] else {
                    assertionFailure("This index is non existent 😵")
                    return
                }
                tabBarVC.tabBar.selectedItem = newSelectedItem
                tabBarVC.selectedIndex = index.rawValue

                if let segmentIndex = segmentIndex, let segmentedController = tabBarVC.currentViewController as? SegmentedController  {
                    segmentedController.loadViewIfNeeded()
                    segmentedController.switchSegment(to: segmentIndex)
                }
                
//            case .documents://because their index is more then two. And we have one offset for button selection but when we point to array index we need - 1 for those items where index > 2.
//                guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index.rawValue] else {
//                    assertionFailure("This index is non existent 😵")
//                    return
//                }
//                tabBarVC.tabBar.selectedItem = newSelectedItem
                tabBarVC.selectedIndex = index.rawValue - 1
            
            default:
                break
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
        openMyDisk()
    }
    
    private func openFloatingMenu() {
        guard let tabBarVC = UIApplication.topController() as? TabBarViewController else {
            return
        }
        
        tabBarVC.showRainbowIfNeed()
    }
    
//    private func openAllFiles() {
//        openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.allFiles.rawValue)
//    }
    
    private func openMyDisk() {
        if let folder = PrivateSharedFolderItem.rootFolder {
            pushTo(router.sharedFolder(rootShareType: .innerFolder(type: .byMe, folderItem: folder), folder: folder))
        } else {
            assertionFailure()
        }
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
    
    private func openContactUs() {
        router.showFeedbackSubView()
    }
    
    private func openUsageInfo() {
        pushTo(router.usageInfo)
    }
    
    private func openRecentActivities() {
        pushTo(router.vcActivityTimeline)
    }
    
    private func openEmail() {
        if let userInfo = SingletonStorage.shared.accountInfo {
            pushTo(router.userProfile(userInfo: userInfo))
        }
    }
    
    private func openFaq() {
        pushTo(router.helpAndSupport)
    }
    
    private func openPasscode() {
        let isTurkcellAccount = SingletonStorage.shared.isTurkcellUser
        pushTo(router.passcodeSettings(isTurkcell: isTurkcellAccount, inNeedOfMail: false))
    }
      
    private func openSearch() {
        let output = router.getViewControllerForPresent()
        let controller = router.searchView(navigationController: output?.navigationController, output: output as? SearchModuleOutput)
        pushTo(controller)
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
    
    private func openSupport(type: SupportFormScreenType) {
        let controller = SupportFormController.with(screenType: type)
        pushTo(controller)
    }
    
    private func openSharedWithMe() {
        openSharedController(type: .withMe)
    }
    
    private func openShareByMe() {
        openSharedController(type: .byMe)
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
