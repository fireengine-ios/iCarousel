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
    
    func assignNotificationActionBy(userInfo: [AnyHashable: Any]) -> Bool {
        guard let actionString = userInfo["action"] as? String else {
            return false
        }

        notificationAction = PushNotificationAction(rawValue: actionString)
        
        if notificationAction == .http {
            notificationActionURLString = actionString
        }
        
        return notificationAction != nil
    }
    
    func openActionScreen() {
        guard let action = notificationAction, tokenStorage.accessToken != nil else {
            return
        }
        
        switch action {
        case .main: openMain()
        case .syncSettings: openSyncSettings()
        case .floatingMenu: openFloatingMenu()
        case .packages: openPackages()
        case .photos: openPhotos()
        case .albums: openAlbums()
        case .allFiles: openAllFiles()
        case .music: openMusic()
        case .documents: openDocuments()
        case .contactSync: openContactSync()
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
        }
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
            tabBarVC.tabBar.selectedItem = tabBarVC.tabBar.items?[index.rawValue]
            tabBarVC.selectedIndex = index.rawValue
        }
    }
    
    //MARK: - Actions
    
    private func openMain() {
        openTabBarItem(index: .homePageScreenIndex)
    }
    
    private func openSyncSettings() {
        pushTo(router.autoUpload)
    }
    
    private func openFloatingMenu() {
        
    }
    
    private func openPackages() {
        pushTo(router.packages)
    }
    
    private func openPhotos() {
        openTabBarItem(index: .photosScreenIndex)
    }
    
    private func openAlbums() {
        pushTo(router.albumsListController())
    }
    
    private func openAllFiles() {
        pushTo(router.allFiles(moduleOutput: nil, sortType: .AlphaBetricAZ, viewType: .List))
    }
    
    private func openMusic() {
        openTabBarItem(index: .musicScreenIndex)
    }
    
    private func openDocuments() {
        openTabBarItem(index: .documentsScreenIndex)
    }
    
    private func openContactSync() {
        pushTo(router.syncContacts)
    }
    
    private func openFavorites() {
        pushTo(router.favorites(moduleOutput: nil, sortType: .AlphaBetricAZ, viewType: .List))
    }
    
    private func openCreateStory() {
        router.createStoryName()
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
        pushTo(router.importPhotos)
    }
    
    private func openSocialMedia() {
        pushTo(router.importPhotos)
    }
    
    private func openFaq() {
        pushTo(router.helpAndSupport)
    }
    
    private func openPasscode() {
        let isTurkcell = SingletonStorage.shared.accountInfo?.accountType == "TURKCELL"
        pushTo(router.passcodeSettings(isTurkcell: isTurkcell, inNeedOfMail: false))
    }
    
    private func openLoginSettings() {
        if let userInfo = SingletonStorage.shared.accountInfo {
            pushTo(router.userProfile(userInfo: userInfo))
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
    
    private func openURL(_ path: String?) {
        guard let path = path, let url = URL(string: path) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
