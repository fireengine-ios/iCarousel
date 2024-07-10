//
//  PushNotificationService.swift
//  Depo
//
//  Created by Andrei Novikau on 27.03.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class PushNotificationService {
    
    private init() { }
    
    static let shared = PushNotificationService()
    
    private lazy var router = RouterVC()
    private lazy var tokenStorage: TokenStorage = factory.resolve()
    private lazy var storageVars: StorageVars = factory.resolve()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var utilityAPIService = UtilityAPIService()

    private var notificationAction: PushNotificationAction?
    private var notificationParameters: String?

    /// A pending action that requires login
    private var pendingAction: String?
    private var pendingRefererToken: String?
    private var pendingActionOptions: [AnyHashable: Any]?

    //MARK: -
    
    func assignNotificationActionBy(launchOptions: [AnyHashable: Any]?) -> Bool {
        let action = launchOptions?[PushNotificationParameter.action.rawValue] as? String ?? launchOptions?[PushNotificationParameter.pushType.rawValue] as? String

        guard let actionString = action else {
            return false
        }

        guard let resolvedAction = resolve(actionString: actionString) else {
            return false
        }

        debugLog("received notification with type \(actionString) resolved to \(resolvedAction)")
        parse(options: launchOptions, action: resolvedAction)
        return true
    }
    
    func assignDeepLink(innerLink: String?, options: [AnyHashable: Any]?) -> Bool {
        guard let actionString = innerLink else {
            return false
        }

        guard let resolvedAction = resolve(actionString: actionString) else {
            storageVars.deepLinkParameters = options
            return false
        }

        debugLog("received deepLink with type \(actionString) resolved to \(resolvedAction)")
        parse(options: options, action: resolvedAction)
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

    func assignAndOpenPendingActionIfAny() {
        guard let pendingAction = self.pendingAction else { return }

        debugLog("handling pending action '\(pendingAction)'. Params \(pendingActionOptions ?? [:])")

        let resolved = assignDeepLink(innerLink: pendingAction, options: pendingActionOptions)
        if resolved {
            openActionScreen()
            clearPendingAction()
        }
    }

    private func resolve(actionString: String, tryResolveIfUnknown: Bool = true) -> PushNotificationAction? {
        guard let notificationAction = PushNotificationAction(rawValue: actionString) else {
            debugLog("received unknown notification/deeplink with type \(actionString)")
            if tryResolveIfUnknown {
                resolveUnknownAction(actionString: actionString)
            }
            return nil
        }

        return notificationAction
    }

    func resolveUnknownAction(actionString: String, refererToken: String? = nil) {
        // can't resolve without a token
        guard tokenStorage.accessToken != nil else {
            pendingAction = actionString
            pendingRefererToken = refererToken
            return
        }

        debugLog("trying to resolve unknown action '\(actionString)'")
        utilityAPIService.resolveDeepLink(actionString: actionString) { url in
            guard let resolvedURL = url, let host = resolvedURL.host else { return }

            guard let action = self.resolve(actionString: host, tryResolveIfUnknown: false) else {
                debugLog("unable to resolve unknown action \(actionString) - resolved to \(resolvedURL)")
                return
            }

            debugLog("resolved unknown action \(actionString) to \(action)")
            var options = resolvedURL.queryParameters
            if let refererToken = refererToken {
                options?.updateValue(refererToken, forKey: DeepLinkParameter.paycellToken.rawValue)
            } else if let pendingRefererToken = self.pendingRefererToken {
                options?.updateValue(pendingRefererToken, forKey: DeepLinkParameter.paycellToken.rawValue)
            }
            self.parse(options: options, action: action)
            self.openActionScreen()
            self.clearPendingAction()
        }
    }

    private func parse(options: [AnyHashable: Any]?, action: PushNotificationAction) {
        let isLoggedIn = tokenStorage.accessToken != nil
        
        var loginRequiresActions: [PushNotificationAction] = [.login, .supportFormLogin, .supportFormSignup]
        
        if storageVars.isAppFirstLaunchForPublicSharedItems != true {
            loginRequiresActions.append(.saveToMyLifebox)
        }
        
        let actionRequiresLogin = !action.isContained(in: loginRequiresActions)
        
        if !isLoggedIn && actionRequiresLogin {
            pendingAction = action.rawValue
            pendingActionOptions = options
            return
        }

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
        
        if !isLoggedIn && action.isContained(in: [.saveToMyLifebox]) {
            action = .saveToMyLifebox
        } else if !isLoggedIn && !action.isContained(in: [.supportFormLogin, .supportFormSignup]) {
            action = .login
        }
        
        if isLoggedIn && action.isContained(in: [.login, .widgetLogout]) {
            clear()
            return
        }
                
        switch action {
        case .main, .home: openMain()
        case .syncSettings, .widgetAutoSyncDisabled: openSyncSettings()
        case .packages, .widgetQuota: openMyStorage()
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
        case .loginSettings: openPasscode()
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
        case .albumDetail: openAlbumDetail()
        case .saveToMyLifebox: openSaveToMyLifebox()
        case .brandAmbassador: openBrandAmbassador()
        case .foryou: openForyou()
        case .discover: openDiscover()
        case .drawCampaign: openDrawCampaign()
        case .photoprint: openPhotoPrint()
        case .bestscenegroup: bestscenegroup()
        case .generatedCollage: openGeneratedItemForyou(action: action)
        case .generatedAnimation: openGeneratedItemForyou(action: action)
        case .generatedAlbum: openGeneratedItemForyou(action: action)
        case .campaignAktiflik: openCampaignAkfitlik(action: action)
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

    private func clearPendingAction() {
        pendingAction = nil
        pendingRefererToken = nil
        pendingActionOptions = nil
    }

    private func isExistingViewController(controller: ViewController) -> Bool {
        if let navigationController = self.router.topNavigationController {
            let existingController = navigationController.viewControllers.first(where: { type(of: $0) == type(of: controller) })
            if existingController == navigationController.viewControllers.last {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
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
}

//MARK: - Actions

private extension PushNotificationService {
    func openLogin() {
        if let navigationController = router.topNavigationController, navigationController.viewControllers.contains(where: { $0 is RegistrationViewController }) {
            return
        }

        pushTo(router.loginScreen)
    }

    func openMain() {
        router.openTabBarItem(index: .gallery)
    }

    func openSyncSettings() {
        pushTo(router.autoUpload)
    }

    func openPackages() {
        let viewController = router.myStorage(usageStorage: nil)
        pushTo(viewController)
    }

    func openPhotos() {
        router.openTabBarItem(index: .gallery)
    }

    func openVideos() {
        router.openTabBarItem(index: .gallery)
    }

    func openAlbums() {
        pushTo(router.albumsListController())
    }

    func openStories() {
        pushTo(router.storiesListController())
    }

    func openAllFiles() {
        router.openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.allFiles.rawValue)
    }

    func openDocuments() {
        router.openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.documents.rawValue)
    }

    func openMusic() {
        router.openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.music.rawValue)
    }

    func openFavorites() {
        router.openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.favorites.rawValue)
    }

    func openTrashBin() {
        router.openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.trashBin.rawValue)
    }

    func openContactSync() {
        router.openTabBarItem(index: .contactsSync)
    }

    func openPeriodicContactSync() {
        pushTo(router.periodicContactsSync)
    }

    func openCreateStory() {
        let controller = router.createStory(navTitle: TextConstants.createStory)
        router.pushViewController(viewController: controller)
    }

    func openContactUs() {
        router.showFeedbackSubView()
    }

    func openUsageInfo() {
        pushTo(router.usageInfo)
    }

    func openAutoUpload() {
        pushTo(router.autoUpload)
    }

    func openRecentActivities() {
        pushTo(router.vcActivityTimeline)
    }

    func openEmail() {
        if let userInfo = SingletonStorage.shared.accountInfo {
            pushTo(router.userProfile(userInfo: userInfo))
        }
    }

    func openImportDropbox() {
        pushTo(router.connectedAccounts)
    }

    func openSocialMedia() {
        pushTo(router.connectedAccounts)
    }

    func openFaq() {
        pushTo(router.helpAndSupport)
    }

    func openPasscode() {
        let isTurkcellAccount = SingletonStorage.shared.accountInfo?.accountType == "TURKCELL"
        pushTo(router.passcodeSettings(isTurkcell: isTurkcellAccount, inNeedOfMail: false))
    }

    func openFaceImageRecognition() {
        pushTo(router.faceImage)
    }

    func openPeople() {
        pushTo(router.peopleListController())
    }

    func openThings() {
        pushTo(router.thingsListController())
    }

    func openPlaces() {
        pushTo(router.placesListController())
    }

    func openSearch() {
        let output = router.getViewControllerForPresent()
        let controller = router.searchView(navigationController: output?.navigationController, output: output as? SearchModuleOutput)
        pushTo(controller)
    }

    func openFreeUpSpace() {
        pushTo(router.freeAppSpace())
    }

    func openURL(_ path: String?) {
        guard let path = path, let url = URL(string: path) else {
            return
        }

        UIApplication.shared.openSafely(url)
    }

    func openSettings() {
        pushTo(router.settings)
    }

    func openProfileEdit() {
        SingletonStorage.shared.getAccountInfoForUser(forceReload: false, success: { [weak self] response in
            let vc = self?.router.userProfile(userInfo: response)
            self?.pushTo(vc)
            /// we don't need error handling here
        }, fail: {_ in})

    }

    func openChangePassword() {
        pushTo(router.changePassword)
    }

    func openPhotoPickHistory() {
        pushTo(router.analyzesHistoryController())
    }

    func openMyStorage() {
        let affiliate = storageVars.value(forDeepLinkParameter: .affiliate) as? String
        let refererToken = storageVars.value(forDeepLinkParameter: .paycellToken) as? String
        let viewController = router.myStorage(usageStorage: nil, affiliate: affiliate, refererToken: refererToken)
        pushTo(viewController)
    }

    func openBecomePremium() {
        pushTo(router.premium())
    }

    func openTBMaticPhotos(_ uuidsByString: String?) {
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

    func openSecurityQuestion() {
        debugLog("PushNotificationService try to open Security Question screen")

        let controller = SetSecurityQuestionViewController.initFromNib()
        pushTo(controller)
    }

    func openPermissions() {
        debugLog("PushNotificationService try to open Permission screen")

        let controller = router.permissions
        pushTo(controller)
    }

    func openCampaignDetails() {
        let controller = router.campaignDetailViewController()
        pushTo(controller)
    }

    func openSupport(type: SupportFormScreenType) {
        let controller = SupportFormController.with(screenType: type)
        pushTo(controller)
    }

    func openHiddenBin() {
        let controller = router.hiddenPhotosViewController()
        pushTo(controller)
    }

    func trackIfNeeded(action: PushNotificationAction) {
        guard action.fromWidget else {
            return
        }

        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .openWithWidget, eventLabel: .success)
    }

    func openSharedWithMe() {
        router.openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.share.rawValue, shareType: .sharedWithMe)
    }

    func openShareByMe() {
        router.openTabBarItem(index: .documents, segmentIndex: DocumentsScreenSegmentIndex.share.rawValue, shareType: .sharedByMe)
    }

    func openInvitation() {
        pushTo(router.invitation)
    }

    func openChatbot() {
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

    func openVerifyEmail() {
        if let userInfo = SingletonStorage.shared.accountInfo {
            let profile = router.userProfile(userInfo: userInfo, appearAction: .presentVerifyEmail)
            pushTo(profile)
        }
    }

    func openVerifyRecoveryEmail() {
        if let userInfo = SingletonStorage.shared.accountInfo {
            let profile = router.userProfile(userInfo: userInfo, appearAction: .presentVerifyRecoveryEmail)
            pushTo(profile)
        }
    }

    func openSharedController(type: PrivateShareType) {
        guard let controller = router.sharedFiles as? SegmentedController,
              let index = controller.viewControllers.firstIndex(where: { ($0 as? PrivateShareSharedFilesViewController)?.shareType == type }) else {
            return
        }
        controller.loadViewIfNeeded()
        controller.switchSegment(to: index)
        pushTo(controller)
    }

    func openAlbumDetail() {
        guard let albumUUID = storageVars.value(forDeepLinkParameter: .albumUUID) as? String else { return }
        PhotosAlbumService().getAlbum(for: albumUUID) { response in
            switch response {
            case .success(let data):
                let viewController = self.router.albumDetailController(album: AlbumItem(remote: data), type: .List, status: .active, moduleOutput: nil)
                if self.isExistingViewController(controller: viewController) {
                    self.router.popViewController()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.pushTo(viewController)
                    }
                } else {
                    self.pushTo(viewController)
                }
            case .failed( _):
                UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
            }
        }
    }
    
    func openSaveToMyLifebox() {
        guard let publicToken = storageVars.value(forDeepLinkParameter: .publicToken) as? String else { return }
        let vc = router.publicSharedItems(with: publicToken)
        
        if isExistingViewController(controller: vc as! ViewController) {
            router.popViewController()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.router.pushViewController(viewController: vc)
        }
        
        if tokenStorage.accessToken == nil {
            clear()
        }
    }
    
    func openBrandAmbassador() {
        let root = RouterVC()
        let payCell = root.paycellCampaign()
        root.pushViewController(viewController: payCell)
    }
    
    func openForyou() {
        let root = RouterVC()
        root.openTabBarItem(index: .forYou)
    }
    
    func openDiscover() {
        let root = RouterVC()
        root.openTabBarItem(index: .discover)
    }
    
    func openDrawCampaign() {
        let uuid = storageVars.deepLinkParameters?.first?.value as? String ?? "0"
        let campaignId = Int(uuid) ?? 0
        pushTo(router.drawCampaign(campaignId: campaignId))
    }
    
    func openGeneratedItemForyou(action: PushNotificationAction) {
        let uuid = storageVars.deepLinkParameters?.first?.value
        switch action {
        case .generatedCollage: openPreviewForGeneratedItem(uuid: uuid as? String, action: .generatedCollage)
        case .generatedAnimation: openPreviewForGeneratedItem(uuid: uuid as? String, action: .generatedAnimation)
        case .generatedAlbum: openGeneratedAlbumDetail(uuid: uuid as? String)
        default: print()
        }
    }
    
    func openCampaignAkfitlik(action: PushNotificationAction) {
        let campaignId = storageVars.deepLinkParameters?.first?.value as? String ?? "0"
        var detUrl: String = ""
        var condUrl: String = ""
        lazy var homeCardsService: HomeCardsService = factory.resolve()
        homeCardsService.all { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let campaignResponse = response.filter ({$0.type == .newCampaign && $0.details?["id"].int == Int(campaignId)})
                    if let detailUrl = campaignResponse.first?.details?["detailImagePath"].string {
                        detUrl = detailUrl
                    }
                    if let conditionImage = campaignResponse.first?.details?["conditionImagePath"].string {
                        condUrl = conditionImage
                    }
                    let vc = self?.router.raffle(id: Int(campaignId) ?? 0, url: detUrl, endDateText: "", conditionImageUrl: condUrl)
                    self?.router.pushViewController(viewController: vc!, animated: false)
                    
                case .failed(_):
                    DispatchQueue.toMain {
                        print()
                    }
                }
            }
        }
    }
    
    private func openPreviewForGeneratedItem(uuid: String?, action: PushNotificationAction?) {
        ForYouService().recommendedDeeplink(uuid: uuid ?? "", handler: { [weak self] result in
            switch result {
            case .success(let response):
                self?.showGeneratedItem(item: WrapData(wrapDataResponse: response), action: action)
            case .failed(let error):
                UIApplication.showCustomAlert(title: TextConstants.errorAlert,
                                              message: error.localizedDescription,
                                              image: .custom(Image.iconErrorRed.image),
                                              buttonTitle: TextConstants.ok)
            }
        })
    }
    
    private func showGeneratedItem(item: WrapData, action: PushNotificationAction?) {
        let controller = PVViewerController.with(item: item, action: action)
        let navController = NavigationController(rootViewController: controller)
        router.presentViewController(controller: navController)
    }
    
    func openGeneratedAlbumDetail(uuid: String?) {
        storageVars.albumDetailFromDeeplink = true
        PhotosAlbumService().getAlbum(for: uuid ?? "") { response in
            switch response {
            case .success(let data):
                let viewController = self.router.albumDetailController(album: AlbumItem(remote: data), type: .List, status: .active, moduleOutput: nil)
                if self.isExistingViewController(controller: viewController) {
                    self.router.popViewController()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.pushTo(viewController)
                    }
                } else {
                    self.pushTo(viewController)
                }
            case .failed( _):
                UIApplication.showErrorAlert(message: TextConstants.temporaryErrorOccurredTryAgainLater)
            }
        }
    }
    
    func openPhotoPrint() {
        let isPackage = SingletonStorage.shared.accountInfo?.photoPrintPackage ?? true
        let sendRemaining = SingletonStorage.shared.accountInfo?.photoPrintSendRemaining ?? 0
        let maxSelection = SingletonStorage.shared.accountInfo?.photoPrintMaxSelection ?? 0
        
        if !isPackage {
            openPackages()
        } else {
            if sendRemaining == 0 {
                openForyou()
            } else {
                pushTo(router.photoPrintSelectPhotos())
            }
        }
    }
    
    func bestscenegroup() {
        let router = RouterVC()
        let controller = router.bestSceneAllGroupController()
        router.pushViewController(viewController: controller)
    }
}
