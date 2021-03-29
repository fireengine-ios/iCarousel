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
        guard let action = notificationAction else {
            return
        }
        
        if tokenStorage.accessToken == nil {
            openLogin()
            clear()
        }
                
        switch action {
        case .myDisk: openMyDisk()
        case .settings: openSettings()
        case .agreements: openAgreements()
        case .faq: openFaq()
        case .profile: openProfile()
        case .trashBin: openTrashBin()
        case .sharedWithMe: openSharedWithMe()
        case .sharedByMe: openShareByMe()
        case .sharedArea: openSharedArea()
        default:
            assertionFailure()
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

        tabBarVC.popToRootCurrentNavigationController(animated: true)
    }

    
    //MARK: - Actions
    
    private func openLogin() {
        if let navigationController = router.topNavigationController, navigationController.viewControllers.contains(where: { $0 is RegistrationViewController }) {
            return
        }
        
        pushTo(router.loginScreen)
    }
    
    private func openMyDisk() {
        pushTo(router.myDisk)
    }
    
    private func openSettings() {
        pushTo(router.settings)
    }
    
    private func openAgreements() {
        pushTo(router.agreements)
    }
    
    private func openFaq() {
        pushTo(router.faq)
    }
    
    private func openProfile() {
        SingletonStorage.shared.getAccountInfoForUser(forceReload: false, success: { [weak self] response in
            let vc = self?.router.userProfile(userInfo: response)
            self?.pushTo(vc)
            /// we don't need error handling here
        }, fail: {_ in})
        
    }
    
    private func openTrashBin() {
        pushTo(router.trashBin)
    }
    
    private func openSharedWithMe() {
        openSharedController(type: .withMe)
    }
    
    private func openShareByMe() {
        openSharedController(type: .byMe)
    }
    
    private func openSharedArea() {
        openSharedController(type: .sharedArea)
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
