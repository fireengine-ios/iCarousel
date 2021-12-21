//
//  Router.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/24/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import UIKit

class RouterVC: NSObject {
    
    var splitContr: SplitIpadViewContoller?
    
    var rootViewController: UIViewController? {
        guard let window = UIApplication.shared.keyWindow,
            let rootviewController = window.rootViewController
            else {
                return nil
        }
        return rootviewController
    }
    
    var tabBarController: TabBarViewController? {
        return rootViewController as? TabBarViewController
    }
    
    func getFloatingButtonsArray() -> [FloatingButtonsType] {
        let nController = navigationController
        let viewController = nController?.viewControllers.last
        
        if let segmentedVC = viewController as? SegmentedController,
            let vc = segmentedVC.currentController as? BaseViewController
        {
            return vc.floatingButtonsArray
        }
        
        if let baseViewController = viewController as? BaseViewController {
            return baseViewController.floatingButtonsArray
        }
        
        return [FloatingButtonsType]()
    }
    
    func getParentUUID() -> String {
        //TODO: get rid of getParentUUID
        if topNavigationController?.viewControllers.first is PhotoVideoDetailViewController,
           let viewController = topNavigationController?.viewControllers.last as? BaseViewController {
            return viewController.parentUUID
        } else if let tabBarController = tabBarController,
            let viewControllers = tabBarController.customNavigationControllers[safe: tabBarController.selectedIndex]?.viewControllers,
            let viewController = viewControllers.last as? BaseViewController {
            return viewController.parentUUID
        }
        return ""
    }
    
    func isRootViewControllerAlbumDetail() -> Bool {
        if let tabBarController = tabBarController,
            let viewControllers = tabBarController.customNavigationControllers[safe: tabBarController.selectedIndex]?.viewControllers,
            let viewController = viewControllers.last as? BaseViewController {
            return viewController is AlbumDetailViewController
        } else {
            return navigationController?.viewControllers.last is AlbumDetailViewController
        }
    }
    
    func isTwoFactorAuthViewControllers() -> Bool {
        
        guard let currentViewController = navigationController?.viewControllers.last else {
            return false
        }
        
        return currentViewController is TwoFactorAuthenticationViewController ||
               currentViewController is PhoneVerificationViewController
    }
    
    // MARK: Navigation controller
    
    var navigationController: UINavigationController? {
        if let navController = rootViewController as? UINavigationController {
            return navController
        } else if let tabBarController = tabBarController {
            if let navVC = tabBarController.presentedViewController as? NavigationController {
                return navVC
            } else {
                return tabBarController.activeNavigationController
            }
        } else {
            return nil
        }
    }
    
    var tabBarVC: UINavigationController? {
        if let nav = navigationController,
            let top = nav.topViewController {
            if let n = top as? TabBarViewController {
                return n.activeNavigationController
            }
            if let n = tabBarController {
                return n.activeNavigationController
            }
        } else {
            if let n = tabBarController {
                return n.activeNavigationController
            }
        }
        
        return nil 
    }
    
    var defaultTopController: UIViewController? {
        return UIApplication.topController()
    }
    
    var topNavigationController: UINavigationController? {
        if let navigationController = defaultTopController?.navigationController {
            return navigationController
        }
        return navigationController
    }
    
    func createRootNavigationController(controller: UIViewController) -> UINavigationController {
        
        let navController = NavigationController(rootViewController: controller)
        return navController
    }
    
    func createRootNavigationControllerWithModalStyle(controller: UIViewController) -> UINavigationController {
        let navController = NavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        navController.modalTransitionStyle = .crossDissolve
        return navController
    }
    
    func setNavigationController(controller: UIViewController?) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        window.rootViewController = controller
        window.isHidden = false
//        window.makeKeyAndVisible()
    }
    
    func pushViewControllertoTableViewNavBar(viewController: UIViewController, animated: Bool = true) {
        if let tabBarVc = tabBarVC {
            
            tabBarVc.pushViewController(viewController, animated: animated)
            return
        }
    }
    
    func pushOnPresentedView(viewController: UIViewController) {
        OrientationManager.shared.lock(for: .portrait, rotateTo: .portrait)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.getViewControllerForPresent()?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func pushViewController(viewController: UIViewController, animated: Bool = true) {
        if let viewController = viewController as? BaseViewController, !viewController.needToShowTabBar {
            NotificationCenter.default.post(name: .hideTabBar, object: nil)
        }
        
        if let navController = topNavigationController {
            navController.pushViewController(viewController, animated: animated)
        } else {
            pushViewControllertoTableViewNavBar(viewController: viewController, animated: animated)
        }
    
        viewController.navigationController?.isNavigationBarHidden = false
        
        if let tabBarViewController = tabBarController, let baseView = viewController as? BaseViewController {
            tabBarViewController.setBGColor(color: baseView.getBackgroundColor())
        }
    }
    
    func pushViewControllerAndRemoveCurrentOnCompletion(_ viewController: UIViewController) {
        if let viewController = viewController as? BaseViewController, !viewController.needToShowTabBar {
            NotificationCenter.default.post(name: .hideTabBar, object: nil)
        }
        
        navigationController?.pushViewControllerAndRemoveCurrentOnCompletion(viewController)
        viewController.navigationController?.isNavigationBarHidden = false
        
        if let tabBarViewController = tabBarController, let baseView = viewController as? BaseViewController {
            tabBarViewController.setBGColor(color: baseView.getBackgroundColor())
        }
        
    }
    
    func pushSeveralControllers(_ viewControllers: [UIViewController], animated: Bool = true) {
        if let viewController = viewControllers.last as? BaseViewController, !viewController.needToShowTabBar {
            NotificationCenter.default.post(name: .hideTabBar, object: nil)
        }
        
        var viewControllersStack = navigationController?.viewControllers ?? []
        viewControllersStack.append(contentsOf: viewControllers)

        navigationController?.setViewControllers(viewControllersStack, animated: animated)
        viewControllers.last?.navigationController?.setNavigationBarHidden(false, animated: false)

        if let tabBarViewController = tabBarController, let baseView = viewControllers.last as? BaseViewController {
            tabBarViewController.setBGColor(color: baseView.getBackgroundColor())
        }
    }
    
    func setBackgroundColor(color: UIColor) {
        if let tabBarViewController = tabBarController {
            tabBarViewController.setBGColor(color: color)
        }
    }
    
    func pushViewControllerWithoutAnimation(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: false)
        viewController.navigationController?.isNavigationBarHidden = false
    }
    
    func replaceTopViewControllerWithViewController(_ viewController: UIViewController, animated: Bool = true) {
        var currentNavigationStack = navigationController?.viewControllers ?? []
        
        if currentNavigationStack.isEmpty {
            pushViewController(viewController: viewController, animated: animated)
        } else {
            currentNavigationStack[currentNavigationStack.count - 1] = viewController
            navigationController?.setViewControllers(currentNavigationStack, animated: true)
        }
    }
    
    func popToRootViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    func popToViewController(_ vc: UIViewController) {//}, completion: VoidHandler? = nil) {
        
        func getNavigation(from navigation: UINavigationController?) -> UINavigationController? {
            var navigationVC: UINavigationController?
            
            if let navVC = navigation, navVC.viewControllers.contains(vc) {
                navigationVC = navVC
                
            } else if let presentingVC = navigation?.presentingViewController {
                var navController: UINavigationController? = nil
                
                if let navVC = presentingVC as? UINavigationController {
                    navController = getNavigation(from: navVC)
                    
                } else if let navVC = presentingVC.navigationController  {
                    navController = getNavigation(from: navVC)
                    
                } else if let tabBar = presentingVC as? TabBarViewController {
                    navController = getNavigation(from: tabBar.currentViewController?.navigationController)
                    
                } else {
                    return navController
                }
                
                if navController?.viewControllers.contains(vc) == true {
                    navigationVC = navController
                }
            }
            
            return navigationVC
        }
        
        if let navigation = getNavigation(from: navigationController) {
            let pop: () -> Void = {
                navigation.popToViewController(vc, animated: true)
            }
            
            if let presentedVC = navigation.presentedViewController {
                presentedVC.dismiss(animated: true) {
                    pop()
                }
            } else {
                pop()
            }
        } else {
            assertionFailure("didn't found comfortable UINavigationController")
        }
    }
    
    func popCreateStory() {
        if let viewControllers = navigationController?.viewControllers {
            var index: Int? = nil
            
            for (i, viewController) in viewControllers.enumerated() {
                if viewController is CreateStorySelectionController
                    || viewController is CreateStoryViewController
                    || viewController is CreateStoryPhotoSelectionController {
                    index = i
                    break
                }
            }

            if let ind = index {
                let viewController = viewControllers[ind - 1]
                navigationController?.popToViewController(viewController, animated: true)
            } else {
                navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func popTwoFactorAuth() {
        guard let viewControllers = navigationController?.viewControllers else {
            assertionFailure("nav bar is missing!")
            return
        }
        
        let index = (viewControllers.enumerated().first(where: { $0.element is TwoFactorAuthenticationViewController }))?.offset
        
        if let index = index {
            let viewController = viewControllers[index - 1]
            navigationController?.popToViewController(viewController, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func getViewControllerForPresent() -> UIViewController? {
        if let nController = topNavigationController?.presentedViewController as? UINavigationController,
            let viewController = nController.viewControllers.first as? PhotoVideoDetailViewController {
            return viewController
        }
        // for present actionSheet under modal controller
        if let presentedController = navigationController?.viewControllers.last?.presentedViewController as? TBMatikPhotosViewController {
            return presentedController
        }
        
        if let navBarController = navigationController?.viewControllers.last?.presentedViewController as? UINavigationController {
            return navBarController.visibleViewController
        }
        
        return navigationController?.viewControllers.last
    }
        
    func presentViewController(controller: UIViewController, animated: Bool = true, completion: VoidHandler? = nil) {
        controller.checkModalPresentationStyle()
        
        OrientationManager.shared.lock(for: .portrait, rotateTo: .portrait)
        if let lastViewController = getViewControllerForPresent() {
            if controller.popoverPresentationController?.sourceView == nil,
                controller.popoverPresentationController?.barButtonItem == nil {
                controller.popoverPresentationController?.sourceView = lastViewController.view
            }
            lastViewController.present(controller, animated: animated, completion: {
                completion?()
            })
        } else {
            assertionFailure("top vc: \(String(describing: UIApplication.topController()))")
            UIApplication.topController()?.present(controller, animated: animated, completion: completion)
        }
    }
        
    func showSpiner() {
        if let lastViewController = getViewControllerForPresent() {
            lastViewController.showSpinnerIncludeNavigationBar()
        }
    }
    
    func hideSpiner() {
        if let lastViewController = getViewControllerForPresent() {
            lastViewController.hideSpinnerIncludeNavigationBar()
        }
    }
    
    func isOnFavoritesView() -> Bool {
        guard let tabBarVc = tabBarVC else {
            return false
        }
        
        if let contr = tabBarVc.viewControllers.last as? BaseFilesGreedViewController {
            return contr.isFavorites
        } else if let contr = tabBarVc.viewControllers.last as? SegmentedController,
            let currentVC = contr.currentController as? BaseFilesGreedViewController
        {
            return currentVC.isFavorites
        }
        
        return false
    }
    
    
    var sharedFolderItem: PrivateSharedFolderItem? {
        guard
            let tabBarVC = tabBarController,
            let navVC = tabBarVC.activeNavigationController,
            let controller = navVC.topViewController as? PrivateShareSharedFilesViewController
        else {
            return nil
        }

        if case let PrivateShareType.innerFolder(type: _, folderItem: folder) = controller.shareType {
            return folder
        }
        
        return nil
    }
    
    // MARK: Splash
    
    var splash: UIViewController? {
        let controller = SplashModuleInitializer.initializeViewController(with: "SplashViewController")
        return controller
    }

    
    // MARK: Onboarding
    
    var onboardingScreen: UIViewController? {
        let conf = IntroduceModuleInitializer()
        let viewController = IntroduceViewController(nibName: "IntroduceViewController",
                                                     bundle: nil)
        conf.introduceViewController = viewController
        conf.setupVC()
        
        return createRootNavigationController(controller: viewController)
    }
    
    
    // MARK: Registartion
    var registrationScreen: UIViewController? {
        let inicializer = RegistrationModuleInitializer()
        let registerController = RegistrationViewController(nibName: "RegistrationScreen",
                                                            bundle: nil)
        inicializer.registrationViewController = registerController
        inicializer.setupVC()
        return registerController
    }
    
    var loginScreen: UIViewController? {
        
        let inicializer = LoginModuleInitializer()
        let loginController = LoginViewController(nibName: "LoginViewController",
                                                  bundle: nil)
        inicializer.loginViewController = loginController
        inicializer.setupVC()
        return loginController
    }
    
    var forgotPasswordScreen: UIViewController? {
        let inicializer = ForgotPasswordModuleInitializer()
        let controller = ForgotPasswordViewController(nibName: "ForgotPasswordViewController",
                                                      bundle: nil)
        inicializer.forgotpasswordViewController = controller
        inicializer.setupVC()
        return controller
    }
    
    func phoneVerificationScreen(withSignUpSuccessResponse signupResponse: SignUpSuccessResponse,
                                 userInfo: RegistrationUserInfoModel) -> UIViewController {

        return PhoneVerificationModuleInitializer.viewController(signupResponse: signupResponse,
                                                                 userInfo: userInfo)
    }
    
    // MARK: SyncContacts
    
    var syncContacts: UIViewController {
        return ContactSyncViewController.initFromNib()
    }
    
    func contactSyncResultController(with view: UIView, navBarTitle: String) -> UIViewController {
        return ContactSyncOperationResultController.create(with: view, navBarTitle: navBarTitle)
    }
    
    // MARK: PeriodicContacsSync
    
    var periodicContactsSync: UIViewController {
        let viewController = PeriodicContactSyncInitializer.initializeViewController(with: "PeriodicContactSyncViewController")
        return viewController
    }
    
    func manageContacts(moduleOutput: ManageContactsModuleOutput?) -> UIViewController {
        let viewController = ManageContactsModuleInitializer.initializeViewController(with: "ManageContactsViewController", moduleOutput: moduleOutput)
        return viewController
    }
    
    func deleteContactDuplicates(analyzeResponse: [ContactSync.AnalyzedContact]) -> UIViewController {
        return DeleteDuplicatesViewController.with(contacts: analyzeResponse)
    }
    
    func contactList(backUpInfo: ContactBackupItem, delegate: ContactListViewDelegate?) -> UIViewController {
        return ContactListViewController.with(backUpInfo: backUpInfo, delegate: delegate)
    }
    
    func contactDetail(with contact: RemoteContact) -> UIViewController {
        return ContactListDetailViewController.with(contact: contact)
    }
    
    func backupHistory() -> UIViewController {
        return ContactsBackupHistoryController()
    }
    
    // MARK: Terms
    
    func termsAndServicesScreen(login: Bool, delegate: RegistrationViewDelegate? = nil, phoneNumber: String?, signUpResponse: SignUpSuccessResponse? = nil, userInfo: RegistrationUserInfoModel? = nil) -> UIViewController {
        let conf = TermsAndServicesModuleInitializer(delegate: delegate)
        let viewController = TermsAndServicesViewController(nibName: "TermsAndServicesScreen",
                                                             bundle: nil)
        
        if let signUpResponse = signUpResponse, let userInfo = userInfo {
            conf.setupConfig(withViewController: viewController, fromLogin: login, withSignUpSuccessResponse: signUpResponse, userInfo: userInfo, phoneNumber: phoneNumber)
        } else {
            conf.setupConfig(withViewController: viewController, fromLogin: login, phoneNumber: phoneNumber )
        }
        return viewController
    }
    
    // MARK: Clean EULA
    
    lazy var termsOfUseScreen = TermsOfUseInitializer.viewController
    
    
    // MARK: SynchronyseSettings
    
    var synchronyseScreen: UIViewController {
        return AutoSyncModuleInitializer.initializeViewController()
    }
    
    
    // MARK: Capcha
    
    var capcha: CaptchaViewController? {
        return CaptchaViewController.initFromXib()
    }
    
    
    // MARK: TabBar
    
    var tabBarScreen: UIViewController? {
        let controller = TabBarViewController(nibName: "TabBarView", bundle: nil)
        return controller
    }
    
    
    // MARK: Home Page
    var homePageScreen: UIViewController? {
        if (!SingletonStorage.shared.isAppraterInited) {
            AppRater.sharedInstance().daysUntilPrompt = 5
            AppRater.sharedInstance().launchesUntilPrompt = 10
            AppRater.sharedInstance().remindMeDaysUntilPrompt = 15
            AppRater.sharedInstance().remindMeLaunchesUntilPrompt = 10
            AppRater.sharedInstance().appLaunched()
            
            SingletonStorage.shared.isAppraterInited = true
        }
        
        let controller = HomePageModuleInitializer.initializeViewController(with: "HomePage")
        return controller
    }
    
    func segmentedMedia() -> PhotoVideoSegmentedController {
        let photos = PhotoVideoController.initPhotoFromNib()
        let videos = PhotoVideoController.initVideoFromNib()
        
        return PhotoVideoSegmentedController.initPhotoVideoSegmentedControllerWith([photos, videos]) 
    }
    
    // MARK: Music
    
    var musics: UIViewController? {
        let controller = MusicInitializer.initializeViewController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    var favorites: UIViewController? {
        let storage = ViewSortStorage.shared
        return favorites(moduleOutput: storage,
                         sortType: storage.favoritesSortType,
                         viewType: storage.favoritesViewType)
    }
    
    var allFiles: UIViewController? {
        let storage = ViewSortStorage.shared
        let controller = allFiles(moduleOutput: storage,
                                  sortType: storage.allFilesSortType,
                                  viewType: storage.allFilesViewType)
        controller.title = TextConstants.homeButtonAllFiles
        
        return controller
    }
    
    var trashBin: UIViewController? {
        let controller = trashBinController()
        controller.segmentImage = .trashBin
        return controller
    }
    
    var shareByMeSegment: UIViewController {
        let controller = PrivateShareSharedFilesViewController.with(shareType: .byMe)
        controller.segmentImage = .sharedByMe
        return controller
    }
    
    var segmentedFiles: UIViewController? {
        guard let musics = musics, let documents = documents, let favorites = favorites, let allFiles = allFiles, let trashBin = trashBin else {
            assertionFailure()
            return SegmentedController()
        }
        let controllers = [allFiles, shareByMeSegment, documents, musics, favorites, trashBin]
        return AllFilesSegmentedController.initWithControllers(controllers, alignment: .adjustToWidth)
    }
    
    var sharedFiles: UIViewController {
        return SegmentedController.initWithControllers([sharedWithMe, sharedByMe], alignment: .center)
    }
    
    var sharedWithMe: UIViewController {
        return PrivateShareSharedFilesViewController.with(shareType: .withMe)
    }
    
    var sharedByMe: UIViewController {
        return PrivateShareSharedFilesViewController.with(shareType: .byMe)
    }
    
    func sharedFolder(rootShareType: PrivateShareType, folder: PrivateSharedFolderItem) -> UIViewController {
        return PrivateShareSharedFilesViewController.with(shareType: .innerFolder(type: rootShareType, folderItem: folder))
    }
    
    // MARK: Music Player
    
    func musicPlayer(status: ItemStatus) -> UIViewController {
        return VisualMusicPlayerModuleInitializer.initializeVisualMusicPlayerController(with: "VisualMusicPlayerViewController", status: status)
    }
    
    
    // MARK: All Files
    
    func allFiles(moduleOutput: BaseFilesGreedModuleOutput?, sortType: MoreActionsConfig.SortRullesType, viewType: MoreActionsConfig.ViewType) -> UIViewController {
        let controller = BaseFilesGreedModuleInitializer.initializeAllFilesViewController(with: "BaseFilesGreedViewController",
                                                                                          moduleOutput: moduleOutput,
                                                                                          sortType: sortType,
                                                                                          viewType: viewType)
        return controller
    }
    
    
    // MARK: Favorites
    
    func favorites(moduleOutput: BaseFilesGreedModuleOutput?, sortType: MoreActionsConfig.SortRullesType, viewType: MoreActionsConfig.ViewType) -> UIViewController {
        let controller = BaseFilesGreedModuleInitializer.initializeFavoritesViewController(with: "BaseFilesGreedViewController",
                                                                                           moduleOutput: moduleOutput,
                                                                                           sortType: sortType,
                                                                                           viewType: viewType)
        return controller
    }
    
    
    // MARK: Folder
    
    func filesFromFolder(folder: Item, type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, status: ItemStatus, moduleOutput: BaseFilesGreedModuleOutput?, alertSheetExcludeTypes: [ElementTypes]? = nil) -> UIViewController {
        let controller = BaseFilesGreedModuleInitializer.initializeFilesFromFolderViewController(with: "BaseFilesGreedViewController",
                                                                                                 folder: folder,
                                                                                                 type: type,
                                                                                                 sortType: sortType,
                                                                                                 status: status,
                                                                                                 moduleOutput: moduleOutput,
                                                                                                 alertSheetExcludeTypes: alertSheetExcludeTypes)

        return controller
    }
    
    
    // MARK: User profile
    
    func userProfile(userInfo: AccountInfoResponse,
                     isTurkcellUser: Bool = false,
                     appearAction: UserProfileAppearAction? = nil) -> UIViewController {
        let viewController = UserProfileModuleInitializer.initializeViewController(
            userInfo: userInfo,
            isTurkcellUser: isTurkcellUser,
            appearAction: appearAction
        )
        return viewController
    }
    
    
    // MARK: File info
    
    func fileInfo(item: BaseDataSourceItem) -> UIViewController {
        let viewController = FileInfoModuleInitializer.initializeViewController(with: "FileInfoViewController",
                                                                                item: item)
        return viewController
    }
    
    
    // MARK: Documents
    
    var documents: UIViewController? {
        let controller = BaseFilesGreedModuleInitializer.initializeDocumentsViewController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    
    // MARK: Create Folder
    
    func createNewFolder(rootFolderID: String?, isFavorites: Bool = false) -> UIViewController {
        let controller = SelectNameModuleInitializer.initializeViewController(with: .selectFolderName, rootFolderID: rootFolderID, isFavorites: isFavorites)
        return controller
    }
    
    func createNewFolderSharedWithMe(parameters: CreateFolderSharedWithMeParameters) -> UIViewController {
        let controller = SelectNameModuleInitializer.with(parameters: parameters)
        return controller
    }
    
    
    // MARK: Create Album
    
    func createNewAlbum(moduleOutput: SelectNameModuleOutput? = nil) -> UIViewController {
        let controller = SelectNameModuleInitializer.initializeViewController(with: .selectAlbumName, moduleOutput: moduleOutput)
        return controller
    }
    
    // MARK: - SearchView
    
    func searchView(navigationController: UINavigationController?, output: SearchModuleOutput? = nil) -> UIViewController {
        let controller = SearchViewInitializer.initializeSearchViewController(with: "SearchView", output: output)
        navigationController?.delegate = controller
        controller.transitioningDelegate = controller
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        return controller
    }
    
    // MARK: CreateStory audio selection
    
    func audioSelection(forStory story: PhotoStory) -> CreateStoryAudioSelectionItemViewController {
        let viewController = CreateStoryAudioSelectionItemViewController(forStory: story)
        return viewController
    }
    
    // MARK: CreateStory preview
    
    func storyPreview(forStory story: PhotoStory, response: CreateStoryResponse) -> UIViewController {
        let controller = CreateStoryPreviewModuleInitializer.initializePreviewViewControllerForStory(with: "CreateStoryPreviewViewController",
                                                                                                   story: story,
                                                                                                   response: response)
        return controller
    }
    
    // MARK: Upload All files
    
    func uploadPhotos() -> UIViewController {
        let controller = LocalAlbumModuleInitializer.initializeLocalAlbumsController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    func uploadPhotos(rootUUID: String,
                      getItems: LocalAlbumPresenter.PassBaseDataSourceItemsHandler?,
                      saveItems: LocalAlbumPresenter.ReturnBaseDataSourceItemsHandler?) -> UIViewController {
        let controller = UploadFilesSelectionModuleInitializer.initializeUploadPhotosViewController(rootUUID: rootUUID,
                                                                                                    getItems: getItems,
                                                                                                    saveItems: saveItems)
        return controller
    }
    
    func uploadFromLifeBox(
        folderUUID: String,
        soorceUUID: String = "",
        sortRule: SortedRules = .timeUp,
        type: MoreActionsConfig.ViewType = .Grid
    ) -> UIViewController {
        if isRootViewControllerAlbumDetail() {
            return UploadFromLifeBoxModuleInitializer.initializePhotoVideosViewController(with: "BaseFilesGreedViewController",
                                                                                          albumUUID: folderUUID)
        } else {
            return UploadFromLifeBoxModuleInitializer
                .initializeFilesForFolderViewController(with: "BaseFilesGreedViewController",
                                                        destinationFolderUUID: folderUUID,
                                                        outputFolderUUID: soorceUUID,
                                                        sortRule: sortRule, type: type)
        }
    }
    
    func uploadFromLifeBoxFavorites(folderUUID: String, soorceUUID: String = "", sortRule: SortedRules = .timeUp, isPhotoVideoOnly: Bool) -> UIViewController {
        return UploadFromLifeBoxModuleInitializer
            .initializeUploadFromLifeBoxFavoritesController(destinationFolderUUID: folderUUID,
                                                            outputFolderUUID: soorceUUID,
                                                            sortRule: sortRule,
                                                            isPhotoVideoOnly: isPhotoVideoOnly)
    }
    
    // MARK: Select Folder view controller
    
    func selectFolder(folder: Item?, sortRule: SortedRules = .timeUp) -> SelectFolderViewController {
        let controller = SelectFolderModuleInitializer.initializeSelectFolderViewController(with: "BaseFilesGreedViewController",
                                                                                            folder: folder,
                                                                                            sortRule: sortRule)
        return controller
    }
    
    func augumentRealityDetailViewController(fileObject: WrapData) -> UIViewController {
        let controller = AugmentedRealityInitializer.initializeController(with: fileObject)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        return controller
    }
    
    func filesDetailModule(fileObject: WrapData, items: [WrapData], status: ItemStatus, canLoadMoreItems: Bool, moduleOutput: PhotoVideoDetailModuleOutput?) -> PhotoVideoDetailModule {
        return PhotoVideoDetailModuleInitializer.initializeViewController(with: "PhotoVideoDetailViewController",
                                                                          moduleOutput: moduleOutput,
                                                                          selectedItem: fileObject,
                                                                          allItems: items,
                                                                          status: status,
                                                                          canLoadMoreItems: canLoadMoreItems)
    }
    
    func filesDetailAlbumModule(fileObject: WrapData, items: [WrapData], albumUUID: String, status: ItemStatus, moduleOutput: PhotoVideoDetailModuleOutput?) -> PhotoVideoDetailModule {
        return PhotoVideoDetailModuleInitializer.initializeAlbumViewController(with: "PhotoVideoDetailViewController",
                                                                               moduleOutput: moduleOutput,
                                                                               selectedItem: fileObject,
                                                                               allItems: items,
                                                                               albumUUID: albumUUID,
                                                                               status: status)
    }
    
    func filesDetailFaceImageAlbumModule(fileObject: WrapData, items: [WrapData], albumUUID: String, albumItem: Item?, status: ItemStatus, moduleOutput: PhotoVideoDetailModuleOutput?, faceImageType: FaceImageType?) -> PhotoVideoDetailModule {
        return PhotoVideoDetailModuleInitializer.initializeFaceImageAlbumViewController(with: "PhotoVideoDetailViewController",
                                                                                        moduleOutput: moduleOutput,
                                                                                        selectedItem: fileObject,
                                                                                        allItems: items,
                                                                                        albumUUID: albumUUID,
                                                                                        albumItem: albumItem,
                                                                                        status: status,
                                                                                        faceImageType: faceImageType)
    }

    // MARK: Albums list
    
    func albumsListController(moduleOutput: LBAlbumLikePreviewSliderModuleInput? = nil) -> BaseFilesGreedChildrenViewController {
        let controller = AlbumsModuleInitializer.initializeAlbumsController(with: "BaseFilesGreedViewController", moduleOutput: moduleOutput)
        return controller
    }
    
    // MARK: Adding photos to album
    
    func addPhotosToAlbum(photos: [BaseDataSourceItem]) -> AlbumSelectionViewController {
        let controller = AlbumsModuleInitializer.initializeSelectAlbumsController(with: "BaseFilesGreedViewController", photos: photos)
        return controller
    }
    
    // MARK: Album detail
    
    func albumDetailController(album: AlbumItem, type: MoreActionsConfig.ViewType, status: ItemStatus, moduleOutput: BaseFilesGreedModuleOutput?) -> AlbumDetailViewController {
        let controller = AlbumDetailModuleInitializer.initializeAlbumDetailController(with: "BaseFilesGreedViewController", album: album, type: type, status: status, moduleOutput: moduleOutput)
        return controller
    }
    
    // MARK: Stories list
    
    func storiesListController(moduleOutput: LBAlbumLikePreviewSliderModuleInput? = nil) -> BaseFilesGreedChildrenViewController {
        let controller = StoriesInitializer.initializeStoriesController(with: "BaseFilesGreedViewController", moduleOutput: moduleOutput)
        return controller
    }
    
    // MARK: People list
    
    func peopleListController(moduleOutput: LBAlbumLikePreviewSliderModuleInput? = nil) -> BaseFilesGreedChildrenViewController {
        let controller = FaceImageItemsInitializer.initializePeopleController(with: "BaseFilesGreedViewController", moduleOutput: moduleOutput)
        return controller as! BaseFilesGreedChildrenViewController
    }
    
    // MARK: Thing list
    
    func thingsListController(moduleOutput: LBAlbumLikePreviewSliderModuleInput? = nil) -> BaseFilesGreedChildrenViewController {
        let controller = FaceImageItemsInitializer.initializeThingsController(with: "BaseFilesGreedViewController", moduleOutput: moduleOutput)
        return controller as! BaseFilesGreedChildrenViewController
    }
    
    // MARK: Place list
    
    func placesListController(moduleOutput: LBAlbumLikePreviewSliderModuleInput? = nil) -> BaseFilesGreedChildrenViewController {
        let controller = FaceImageItemsInitializer.initializePlacesController(with: "BaseFilesGreedViewController", moduleOutput: moduleOutput)
        return controller as! BaseFilesGreedChildrenViewController
    }
    
    // MARK: Analyses History page
    
    func analyzesHistoryController() -> AnalyzeHistoryViewController {
        return AnalyzeHistoryViewController.initFromNib()
    }

    // MARK: Invitation page

    func invitationController() -> InvitationViewController {
        return InvitationViewController()
    }
    
    // MARK: Face Image Recognition Photos
    
    func imageFacePhotosController(album: AlbumItem, item: Item, status: ItemStatus, moduleOutput: FaceImageItemsModuleOutput?, isSearchItem: Bool = false, faceImageType: FaceImageType? = nil) -> BaseFilesGreedChildrenViewController {
        let controller = FaceImagePhotosInitializer.initializeController(with: "FaceImagePhotosViewController",
                                                                         album: album,
                                                                         item: item,
                                                                         status: status,
                                                                         moduleOutput: moduleOutput,
                                                                         isSearchItem: isSearchItem,
                                                                         faceImageType: faceImageType)
        return controller as! BaseFilesGreedChildrenViewController
    }
    
    func faceImageChangeCoverController(albumUUID: String, personItem: Item? = nil, coverType: CoverType? = nil, moduleOutput: FaceImageChangeCoverModuleOutput?) -> BaseFilesGreedChildrenViewController {
        let controller = FaceImageChangeCoverInitializer.initializeController(with: "BaseFilesGreedViewController", albumUUID: albumUUID, personItem: personItem, coverType: coverType, moduleOutput: moduleOutput)
        return controller as! BaseFilesGreedChildrenViewController
    }
    
    // MARK: Free App Space
    
    func freeAppSpace() -> UIViewController {
        let controller = FreeAppSpaceModuleInitializer.initializeFreeAppSpaceViewController(with: "FreeAppSpaceViewCotroller")
        return controller
    }
    
    // MARK: - SETTINGS
    
    var settings: UIViewController? {
        let controller = SettingsModuleInitializer.initializeViewController(with: "SettingsViewController")
        return controller
    }
    
    var settingsIpad: UIViewController? {
        let leftController = settings
        let rightController = syncContacts
        
        splitContr = SplitIpadViewContoller()
        splitContr?.configurateWithControllers(leftViewController: leftController as! SettingsViewController, controllers: [rightController])
        
        guard let splitVC = splitContr?.getSplitVC() else {
            return nil
        }
        
        let containerController = EmptyContainerNavVC.setupContainer(withSubVC: splitVC)
        return containerController
    }
    
    // MARK: Help and support
    
    var helpAndSupport: UIViewController {
        let controller = HelpAndSupportModuleInitializer.initializeViewController(with: "HelpAndSupportViewController")
        return controller
    }
    
    // MARK: Terms and policy
    
    var termsAndPolicy: UIViewController? {
        return TermsAndPolicyViewController.initFromNib()
    }
    
    // MARK: Turkcell Security
    
    func turkcellSecurity(isTurkcell: Bool) -> UIViewController {
        return LoginSettingsModuleInitializer.viewController(isTurkcell: isTurkcell)
    }

    // MARK: Invitation

    var invitation: UIViewController {
        return InvitationViewController()
    }

    // MARK: Chatbot

    var chatbot: UIViewController {
        return ChatbotViewController()
    }

    // MARK: Chatbot

    var darkMode: UIViewController {
        return DarkModeInitializer.initializeViewController()
    }

    // MARK: Auto Upload

    var autoUpload: UIViewController {
        return AutoSyncModuleInitializer.initializeViewController(fromSettings: true)
    }
    
    // MARK: Change Password
    
    var changePassword: UIViewController {
        return ChangePasswordController.initFromNib()
    }
    
    // MARK: - Import photos
    
    var connectedAccounts: UIViewController? {
        return ConnectedAccountsViewController.initFromNib()
    }
    
    // MARK: - Permissions
    
    var permissions: UIViewController {
        return PermissionViewController()
    }
    
    // MARK: Face image
    
    var faceImage: UIViewController {
        return FaceImageViewController.initFromNib()
    }
    
    // MARK: Face image add name
    
    func faceImageAddName(_ item: WrapData, moduleOutput: FaceImagePhotosModuleOutput?, isSearchItem: Bool) -> UIViewController {
        let controller = FaceImageAddNameInitializer.initializeViewController(with: "FaceImageAddNameViewController", item: item, moduleOutput: moduleOutput, isSearchItem: isSearchItem)
        return controller
    }
    
    // MARK: - Import photos
    
    var usageInfo: UIViewController? {
        let controller = UsageInfoInitializer.initializeViewController(with: "UsageInfoViewController")
        return controller
    }
    
    func instagramAuth(fromSettings: Bool) -> UIViewController {
        return InstagramAuthViewController.controller(fromSettings: fromSettings)
    }
    
    // MARK: OTP
    
    func otpView(response: SignUpSuccessResponse, userInfo: AccountInfoResponse, phoneNumber: String) -> UIViewController {
        let controller = OTPViewModuleInitializer.viewController(response: response, userInfo: userInfo, phoneNumber: phoneNumber)
        return controller
    }
    
    // MARK: feedback subView
    
    func showFeedbackSubView() {
        SingletonStorage.shared.getAccountInfoForUser(success: { userInfo in
            let controller = self.supportFormPrefilledController
            controller.title = TextConstants.feedbackViewTitle
            let config = SupportFormConfiguration(name: userInfo.name,
                                                  surname: userInfo.surname,
                                                  phone: userInfo.fullPhoneNumber,
                                                  email: userInfo.email)
            controller.config = config
            self.pushViewController(viewController: controller)
            
        }, fail: { error in
            UIApplication.showErrorAlert(message: error.description)
        })

    }
    
    func vcForCurrentState() -> UIViewController? {
        return splash
    }
    
    
    // MARK: - Activity Timeline
    
    var vcActivityTimeline: UIViewController {
        return ActivityTimelineModuleInitializer.initialize(ActivityTimelineViewController.self)
    }
    
    
    // MARK: FreeAppSpace
    
    func showFreeAppSpace() {
        let controller = freeAppSpace()
        pushViewController(viewController: controller)
    }
    // MARK: - Packages
    
    func packages(quotaInfo: QuotaInfoResponse? = nil, affiliate: String? = nil) -> PackagesViewController {
        return PackagesModuleInitializer.viewController(quotaInfo: quotaInfo, affiliate: affiliate)
    }

    // MARK: - Passcode
    
    func passcodeSettings(isTurkcell: Bool, inNeedOfMail: Bool) -> UIViewController {
        return PasscodeSettingsModuleInitializer.setupModule(isTurkcell: isTurkcell, inNeedOfMail: inNeedOfMail)
    }
    
    // MARK: - Premium
    
    func premium(source: BecomePremiumViewSourceType = .default, module: FaceImageItemsModuleOutput? = nil, viewControllerForPresentOn: UIViewController? = nil) -> UIViewController{
        let controller = PremiumModuleInitializer.initializePremiumController(source: source, module: module, viewControllerForPresentOn: viewControllerForPresentOn)
        return controller
    }
    
    // MARK: - Leave Premium
    
    func leavePremium(type: LeavePremiumType) -> UIViewController {
        let controller = LeavePremiumModuleInitializer.initializeLeavePremiumController(with: "LeavePremiumViewController",
                                                                                        type: type)
        return controller
    }

    //MARK: - My Storage
    
    func myStorage(usageStorage: UsageResponse?) -> MyStorageViewController {
        let controller = MyStorageModuleInitializer.initializeMyStorageController(usage: usageStorage)
        return controller
    }
    
    func instaPickDetailViewController(models: [InstapickAnalyze], analyzesCount: InstapickAnalyzesCount, isShowTabBar: Bool) -> InstaPickDetailViewController {
        let nibName = String(describing: InstaPickDetailViewController.self)
        let controller = InstaPickDetailViewController(nibName: nibName, bundle: nil)
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        controller.configure(with: models, analyzesCount: analyzesCount, isShowTabBar: isShowTabBar)
        
        return controller
    }
    
    var supportFormPrefilledController: SupportFormPrefilledController {
        return SupportFormPrefilledController()
    }
    
    func createStory(navTitle: String) -> UIViewController {
        return CreateStorySelectionController(title: navTitle, isFavouritePictures: isOnFavoritesView())
    }
    
    func createStory(searchItems: [Item]) -> UIViewController {
        return CreateStoryPhotoSelectionController(photos: searchItems)
    }
    
    func createStory(items: [Item]) -> UIViewController {
        return CreateStoryViewController(images: items)
    }
    
    func twoFactorChallenge(otpParams: TwoFAChallengeParametersResponse, challenge: TwoFAChallengeModel) -> UIViewController {
        return TwoFactorChallengeInitializer.viewController(otpParams: otpParams, challenge: challenge)
    }
    
    var verifyEmailPopUp: VerifyEmailPopUp {
        let controller = VerifyEmailPopUp()
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        return controller
    }

    var verifyRecoveryEmailPopUp: VerifyRecoveryEmailPopUp {
        let controller = VerifyRecoveryEmailPopUp()

        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve

        return controller
    }
    
    var changeEmailPopUp: ChangeEmailPopUp {
        let controller = ChangeEmailPopUp()
        
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        
        return controller
    }
    
    // MARK: - Spotify
    
    func spotifyPlaylistsController(delegate: SpotifyPlaylistsViewControllerDelegate?) -> UIViewController {
        let controller = SpotifyPlaylistsViewController.initFromNib()
        controller.delegate = delegate
        return controller
    }
    
    func spotifyTracksController(playlist: SpotifyPlaylist) -> UIViewController {
        let controller = SpotifyPlaylistViewController.initFromNib()
        controller.playlist = playlist
        return controller
    }
    
    func spotifyImportController(delegate: SpotifyImportControllerDelegate?) -> UIViewController {
        let controller = SpotifyImportViewController.initFromNib()
        controller.delegate = delegate
        return controller
    }
    
    func spotifyOverwritePopup(importAction: @escaping VoidHandler, dismissAction: VoidHandler? = nil) -> UIViewController {
        return SpotifyOverwritePopup.with(action: importAction, dismissAction: dismissAction)
    }
    
    func spotifyDeletePopup(deleteAction: @escaping VoidHandler, dismissAction: VoidHandler? = nil) -> UIViewController {
        return SpotifyDeletePopup.with(action: deleteAction, dismissAction: dismissAction)
    }
    
    func spotifyCancelImportPopup(cancelAction: @escaping VoidHandler, continueAction: VoidHandler? = nil) -> UIViewController {
        return SpotifyCancelImportPopup.with(action: cancelAction, dismissAction: continueAction)
    }

    func spotifyAuthWebViewController(url: URL, delegate: SpotifyAuthViewControllerDelegate?) -> UIViewController {
        let controller = SpotifyAuthViewController()
        controller.loadWebView(with: url)
        controller.delegate = delegate
        return controller
    }
    
    func spotifyImportedPlaylistsController() -> UIViewController {
        return SpotifyImportedPlaylistsViewController.initFromNib()
    }
    
    func spotifyImportedTracksController(playlist: SpotifyPlaylist, delegate: SpotifyImportedTracksViewControllerDelegate?) -> UIViewController {
        let controller = SpotifyImportedTracksViewController.initFromNib()
        controller.playlist = playlist
        controller.delegate = delegate
        return controller
    }
    
    func tbmaticPhotosContoller(uuids: [String]) -> UIViewController {
        return TBMatikPhotosViewController.with(uuids: uuids)
    }
    
    func campaignDetailViewController() -> UIViewController {
        return CampaignDetailViewController.initFromNib()
    }

    func hiddenPhotosViewController() -> UIViewController {
        return HiddenPhotosViewController.initFromNib()
    }
    
    func trashBinController() -> TrashBinViewController {
        return TrashBinViewController.initFromNib()
    }
    
    func showFullQuotaPopUp(_ popUpType: FullQuotaWarningPopUpType = .standard) {
        let controller = FullQuotaWarningPopUp(popUpType)
        DispatchQueue.main.async {
            if
                let topController = self.defaultTopController,
                topController is AutoSyncViewController == false,
                topController is FullQuotaWarningPopUp == false,
                topController is LoginViewController == false {
                topController.present(controller, animated: false)
            }
        }
    }
    
    func mobilePaymentPermissionController() -> MobilePaymentPermissionViewController {
        return MobilePaymentPermissionViewController.initFromNib()
    }
    
    func openTrashBin() {
        guard let tabBarVC = tabBarController else {
            return
        }
        
        tabBarVC.dismiss(animated: true)
        
        func switchToTrashBin() {
            guard let segmentedController = tabBarVC.currentViewController as? SegmentedController else {
                return
            }
            
            segmentedController.loadViewIfNeeded()
            segmentedController.switchSegment(to: DocumentsScreenSegmentIndex.trashBin.rawValue)
        }
        
        let index = TabScreenIndex.documents.rawValue
        if tabBarVC.selectedIndex == index {
            switchToTrashBin()
        } else {
            guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index] else {
                assertionFailure("This index is non existent 😵")
                return
            }
            tabBarVC.tabBar.selectedItem = newSelectedItem
            tabBarVC.selectedIndex = index - 1
            switchToTrashBin()
        }
    }
    
    func privateShare(items: [WrapData]) -> UIViewController {
        let shareController = PrivateShareViewController.with(items: items)
        let navigationController = NavigationController(rootViewController: shareController)
        navigationController.modalTransitionStyle = .coverVertical
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
    
    func privateShareContacts(with shareInfo: SharedFileInfo) -> UIViewController {
        PrivateShareContactsViewController.with(shareInfo: shareInfo)
    }
    
    func privateShareAccessList(projectId: String, uuid: String, contact: SharedContact, fileType: FileType) -> UIViewController {
        PrivateShateAccessListViewController.with(projectId: projectId, uuid: uuid, contact: contact, fileType: fileType)
    }

    func showAccountDeletedPopUp() {
        let popup = DeleteAccountPopUp.with(type: .success)
        defaultTopController?.present(popup, animated: true)
    }
}
