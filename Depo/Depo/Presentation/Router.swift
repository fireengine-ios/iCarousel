//
//  Router.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 6/24/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

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
        if let navController = topNavigationController {
            navController.pushViewController(viewController, animated: animated)
        } else {
            pushViewControllertoTableViewNavBar(viewController: viewController, animated: animated)
        }
    
        viewController.navigationController?.isNavigationBarHidden = false
    }
    
    func pushViewControllerAndRemoveCurrentOnCompletion(_ viewController: UIViewController) {
        navigationController?.pushViewControllerAndRemoveCurrentOnCompletion(viewController)
        viewController.navigationController?.isNavigationBarHidden = false
    }
    
    func pushSeveralControllers(_ viewControllers: [UIViewController], animated: Bool = true) {
        var viewControllersStack = navigationController?.viewControllers ?? []
        viewControllersStack.append(contentsOf: viewControllers)

        navigationController?.setViewControllers(viewControllersStack, animated: animated)
        viewControllers.last?.navigationController?.setNavigationBarHidden(false, animated: false)
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
    
    func popToAnalizeStory() {
        guard let tabBarVC = tabBarController else {
            return
        }
        
        tabBarVC.dismiss(animated: true)
        
        let index = TabScreenIndex.forYou.rawValue
        
        guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index] else {
            assertionFailure("This index is non existent 😵")
            return
        }
        
        tabBarVC.tabBar.selectedItem = newSelectedItem
        tabBarVC.selectedIndex = index
        
        tabBarController?.navigationController?.popToRootViewController(animated: true)
    }
    
    func createCollageToForyou() {
        guard let tabBarVC = tabBarController else {
            return
        }
        
        tabBarVC.dismiss(animated: true)
        
        let index = TabScreenIndex.forYou.rawValue
        
        guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index] else {
            assertionFailure("This index is non existent 😵")
            return
        }
        
        tabBarVC.tabBar.selectedItem = newSelectedItem
        tabBarVC.selectedIndex = index
        
        tabBarController?.navigationController?.popToRootViewController(animated: true)
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

        guard let topViewController = UIApplication.topController() else {
            assertionFailure("top vc: \(String(describing: UIApplication.topController()))")
            return
        }

        // TODO: Facelift, double check this is needed
        if controller.modalPresentationStyle == .popover,
           controller.popoverPresentationController?.sourceView == nil,
           controller.popoverPresentationController?.barButtonItem == nil {
            controller.popoverPresentationController?.sourceView = topViewController.view
        }
        topViewController.present(controller, animated: animated, completion: completion)
    }
    
    func presentViewControllerForShareOriginal(controller: UIViewController, animated: Bool = true, completion: VoidHandler? = nil) {
        controller.checkModalPresentationStyle()
        
        OrientationManager.shared.lock(for: .portrait, rotateTo: .portrait)

        guard let topViewController = tabBarController else {
            assertionFailure("top vc: \(String(describing: UIApplication.topController()))")
            return
        }

        // TODO: Facelift, double check this is needed
        if controller.modalPresentationStyle == .popover,
           controller.popoverPresentationController?.sourceView == nil,
           controller.popoverPresentationController?.barButtonItem == nil {
            controller.popoverPresentationController?.sourceView = topViewController.view
        }
        topViewController.present(controller, animated: animated, completion: completion)
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
    
    func forgotPasswordScreen(loginText: String) -> UIViewController {
        let initializer = ForgotPasswordModuleInitializer()
        let controller = ForgotPasswordViewController(nibName: "ForgotPasswordViewController",
                                                      bundle: nil)
        initializer.forgotpasswordViewController = controller
        initializer.loginText = loginText
        initializer.setupVC()
        return controller
    }
    
    func phoneVerificationScreen(signUpResponse: SignUpSuccessResponse,
                                 userInfo: RegistrationUserInfoModel,
                                 tooManyRequestsError: ServerValueError? = nil) -> UIViewController {

        return PhoneVerificationModuleInitializer.viewController(
            signupResponse: signUpResponse,
            userInfo: userInfo,
            tooManyRequestsError: tooManyRequestsError
        )
    }

    func emailVerificationScreen(signUpResponse: SignUpSuccessResponse,
                                 userInfo: RegistrationUserInfoModel) -> UIViewController {

        return EmailVerificationModuleInitializer.viewController(signupResponse: signUpResponse,
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
    
    func synchronyseScreen(fromSettings: Bool = false, fromRegister: Bool = false) -> UIViewController {
        return AutoSyncModuleInitializer.initializeViewController(fromSettings: fromSettings, fromRegister: fromRegister)
    }
    
    // MARK: TabBar
    var tabBarScreen: UIViewController? {
        return TabBarViewController()
    }
    
    // MARK: Home Page
    var homePageScreen: HeaderContainingViewController.ChildViewController {
        if (!SingletonStorage.shared.isAppraterInited) {
            AppRater.sharedInstance().daysUntilPrompt = 5
            AppRater.sharedInstance().launchesUntilPrompt = 10
            AppRater.sharedInstance().remindMeDaysUntilPrompt = 15
            AppRater.sharedInstance().remindMeLaunchesUntilPrompt = 10
            AppRater.sharedInstance().appLaunched()
            
            SingletonStorage.shared.isAppraterInited = true
        }
        
        return HomePageModuleInitializer.initializeViewController(with: "HomePage")
    }

    func gallery() -> PhotoVideoController {
        return PhotoVideoController.initFromNib()
    }
    
    func forYou() -> HeaderContainingViewController.ChildViewController {
        return ForYouInitilizer.initializeViewController(with: "ForYou")
    }
    
    func discover() -> HeaderContainingViewController.ChildViewController {
        return DiscoverInitilizer.initializeViewController(with: "Discover")
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
    
    var trashBin: UIViewController {
        let controller = trashBinController()
        controller.segmentImage = .trashBin
        return controller
    }
    
    var shareByMeSegment: UIViewController {
        let controller = PrivateShareSharedFilesViewController.with(shareType: .byMe)
        controller.segmentImage = .sharedByMe
        return controller
    }
    
    var documentsAndMusic: UIViewController? {
        let controller = BaseFilesGreedModuleInitializer.initializeDocumentsAndMusicViewController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    var segmentedFiles: HeaderContainingViewController.ChildViewController {
        guard let musics = musics, let documents = documents, let favorites = favorites, let allFiles = allFiles, let documentsAndMusic = documentsAndMusic else {
            assertionFailure()
            return AllFilesSegmentedController()
        }
        let controllers = [documents, musics, favorites, sharedWithMe, trashBin, shareByMeSegment, allFiles, documentsAndMusic]
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
    
    // MARK: Save to my lifebox
    
    func publicSharedItems(with publicToken: String) -> UIViewController {
        let controller = PublicShareInitializer.initializeSaveToMyLifeboxViewController(with: publicToken)
        return controller
    }
    
    func publicSharedItemsInnerFolder(with item: WrapData, itemCount: Int) -> UIViewController {
        let controller = PublicShareInitializer.initializeSaveToMyLifeboxViewController(with: item, itemCount: itemCount)
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
    
    func filesDetailPublicSharedItemModule(fileObject: WrapData, items: [WrapData], status: ItemStatus, canLoadMoreItems: Bool, moduleOutput: PhotoVideoDetailModuleOutput?) -> PhotoVideoDetailModule {
        return PhotoVideoDetailModuleInitializer.initializePublicSharedItem(with: "PhotoVideoDetailViewController",
                                                                            moduleOutput: moduleOutput,
                                                                            selectedItem: fileObject,
                                                                            allItems: items,
                                                                            status: status,
                                                                            canLoadMoreItems: canLoadMoreItems)
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
    
    // MARK: Collage list
    
    func collageListController(moduleOutput: LBAlbumLikePreviewSliderModuleInput? = nil) -> BaseFilesGreedChildrenViewController {
        let controller = CollageInitializer.initializeCollageController(with: "BaseFilesGreedViewController", moduleOutput: moduleOutput)
        return controller
    }
    
    // MARK: Favorite list
    
    func favoriteListController(moduleOutput: LBAlbumLikePreviewSliderModuleInput? = nil) -> BaseFilesGreedChildrenViewController {
        let controller = FavoriteInitializer.initializeFavoriteController(with: "BaseFilesGreedViewController", moduleOutput: moduleOutput)
        return controller
    }
    
    // MARK: Animation list
    
    func animationListController(moduleOutput: LBAlbumLikePreviewSliderModuleInput? = nil) -> BaseFilesGreedChildrenViewController {
        let controller = AnimationsInitializer.initializeAnimationController(with: "BaseFilesGreedViewController", moduleOutput: moduleOutput)
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

    // MARK: Map

    func mapSearchController() -> MapSearchViewController {
        return MapSearchInitializer.initialize()
    }

    func mapLocationDetail(for group: MapMediaGroup) -> MapLocationDetailViewController {
        return MapLocationDetailInitializer.initialize(nibName: "BaseFilesGreedViewController", group: group)
    }
    
    // MARK: Analyses History page
    
    func analyzesHistoryController() -> AnalyzeHistoryViewController {
        return AnalyzeHistoryViewController.initFromNib()
    }

    // MARK: Invitation page

    func invitationController() -> InvitationViewController {
        return InvitationViewController()
    }
    
    func paycellCampaign() -> PaycellCampaignViewController {
        return PaycellCampaignViewController()
    }
    
    // MARK: Best Scene All Group
    
    func bestSceneAllGroupController() -> BestSceneAllGroupViewController {
        return BestSceneAllGroupViewController()
    }
    
    // MARK: Best Scene All Group Sorted
    
    func bestSceneAllGroupSortedViewController(coverPhotoUrl: String, fileListUrls: [String], selectedId: [Int], selectedGroupID: Int) -> BestSceneAllGroupSortedViewController {
        let bestSceneVC = BestSceneAllGroupSortedInitializer.initializeController(coverPhotoUrl: coverPhotoUrl, fileListUrls: fileListUrls, selectedId: selectedId, selectedGroupID: selectedGroupID) as! BestSceneAllGroupSortedViewController
        return bestSceneVC
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
        return UIViewController()
    }

    // MARK: Invitation

    var invitation: UIViewController {
        return InvitationViewController()
    }
    
    var paycell: UIViewController {
        return PaycellCampaignViewController()
    }

    // MARK: Chatbot

    var chatbot: UIViewController {
        return ChatbotViewController()
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
    
    func packages(quotaInfo: QuotaInfoResponse? = nil) -> PackagesViewController {
        return PackagesModuleInitializer.viewController(quotaInfo: quotaInfo)
    }
    
    // MARK: - OnlyOffice
    
    func onlyOffice(fileUuid: String, fileName: String)  -> OnlyOfficeViewController {
        return OnlyOfficeViewController(fileUuid: fileUuid, fileName: fileName)
    }
    
    // MARK: - Notification
    func notification() -> NotificationViewController {
        return NotificationModuleInitializer.initializeViewController()
    }
    
    // MARK: - Settings -> Connected Device
    func connectedDevice() -> ConnectedDeviceViewController {
        return ConnectedDeviceInitializer.initializeViewController()
    }
    
    // MARK: - Raffle - Gamification
    func raffle(id: Int, url: String, endDateText: String) -> RaffleViewController {
        return RaffleInitializer.initializeViewController(id: id, url: url, endDateText: endDateText)
    }
    
    func raffleSummary(statusResponse: RaffleStatusResponse?) -> RaffleSummaryViewController {
        return RaffleSummaryViewController(statusResponse: statusResponse)
    }
    
    // MARK: - Draw Campaign
    func drawCampaign(campaignId: Int) -> DrawCampaignViewController {
        return DrawCampaignInitializer.initializeViewController(campaignId: campaignId)
    }
    
    // MARK: - Garenta
    func garenta(details: String, pageTitle: String) -> GarentaViewController {
        return GarentaViewController(details: details, pageTitle: pageTitle)
    }
    
    // MARK: - Create Collage Template
    
    func createCollage() -> CreateCollageViewController {
        return CreateCollageInitilizer.initializeViewController()
    }
    
    // MARK: - Create Collage Select Photos
    
    func createCollageSelectPhotos(collageTemplate: CollageTemplateElement, items: [SearchItemResponse] = [], selectItemIndex: Int? = nil)  -> CreateCollageSelectionSegmentedController {
        return CreateCollageSelectionSegmentedController(collageTemplate: collageTemplate, items: items, selectItemIndex: selectItemIndex)
    }
    
    // MARK: - Create Collage Preview
    
    func createCollagePreview(collageTemplate: CollageTemplateElement, selectedItems: [SearchItemResponse])  -> CreateCollagePreviewController {
        return CreateCollagePreviewController(collageTemplate: collageTemplate, selectedItems: selectedItems)
    }
    
    // MARK: - Create Collage See All

    func createCollageNavigateToSeeAll(collageTemplate: CollageTemplate, section: CollageTemplateSections)  -> CreateCollageDetailController {
        return CreateCollageDetailController(collageTemplate: collageTemplate, section: section)
    }
    
    // MARK: - PhotoPrint Template
    
    func photoPrintViewController(selectedPhotos: [SearchItemResponse]) -> PhotoPrintViewController {
        return PhotoPrintInitilizer.initializeViewController(selectedPhotos: selectedPhotos)
    }
    
    func photoPrintSelectPhotos(selectedPhotos: [SearchItemResponse] = [], popupShowing: Bool? = nil)  -> PhotoPrintSelectionSegmentedController {
        return PhotoPrintSelectionSegmentedController(selectedPhotos: selectedPhotos, popupShowing: popupShowing ?? false)
    }
    
    func photoPrintForYouViewController(item: [GetOrderResponse] = []) -> PhotoPrintForYouViewController {
        return PhotoPrintForYouViewController(item: item)
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
    
    func myStorage(usageStorage: UsageResponse?, affiliate: String? = nil, refererToken: String? = nil) -> MyStorageViewController {
        let controller = MyStorageModuleInitializer.initializeMyStorageController(usage: usageStorage, affiliate: affiliate, refererToken: refererToken)
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
        
        let story = PhotoStory(name: "")
        story.storyPhotos = items
        
        let router = RouterVC()
        let controller = router.audioSelection(forStory: story)
        controller.fromPhotoSelection = true  
        return controller
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

    var changeRecoveryEmailPopUp: ChangeRecoveryEmailPopUp {
        let controller = ChangeRecoveryEmailPopUp()

        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen

        return controller
    }
    
    func changeEmailPopupForAppleGoogleLoginDisconnect(disconnectAppleGoogleLogin: Bool) -> ChangeEmailPopUp {
        let controller = ChangeEmailPopUp()
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.disconnectAppleGoogleLogin = disconnectAppleGoogleLogin
        
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
        
        let index = TabScreenIndex.documents.rawValue
        if tabBarVC.selectedIndex == index {
            switchToTrashBin()
        } else {
            guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index] else {
                assertionFailure("This index is non existent 😵")
                return
            }
            
            tabBarVC.tabBar.selectedItem = newSelectedItem
            tabBarVC.selectedIndex = index
            
            switchToTrashBin()
        }
    }
        
    func switchToTrashBin() {
        let segmentedController = (tabBarController?.customNavigationControllers[TabScreenIndex.documents.rawValue].viewControllers.first as? HeaderContainingViewController)?.childViewController as? AllFilesSegmentedController

        segmentedController?.loadViewIfNeeded()
        segmentedController?.switchAllFilesCategory(to: DocumentsScreenSegmentIndex.trashBin.rawValue)
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
    
    func openTabBarItem(index: TabScreenIndex, segmentIndex: Int? = nil, shareType: SharedItemsSegment? = nil) {
        guard let tabBarVC = tabBarController  else {
            return
        }
        
        if tabBarVC.selectedIndex != index.rawValue {
            switch index {
            case .forYou:
                guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index.rawValue] else {
                    assertionFailure("This index is non existent 😵")
                    return
                }
                tabBarVC.tabBar.selectedItem = newSelectedItem
                tabBarVC.selectedIndex = index.rawValue
            case .contactsSync, .documents:
                guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index.rawValue] else {
                    assertionFailure("This index is non existent 😵")
                    return
                }
                tabBarVC.tabBar.selectedItem = newSelectedItem
                tabBarVC.selectedIndex = index.rawValue
            
                if let segmentIndex = segmentIndex {
                    ItemOperationManager.default.allFilesSectionChange(to: segmentIndex, shareType: shareType)
                }
            case .gallery:
                tabBarVC.showPhotoScreen()
            case .discover:
                guard let newSelectedItem = tabBarVC.tabBar.items?[safe: index.rawValue] else {
                    assertionFailure("This index is non existent 😵")
                    return
                }
                tabBarVC.tabBar.selectedItem = newSelectedItem
                tabBarVC.selectedIndex = index.rawValue
                //break
            }
        } else {
            tabBarVC.popToRootCurrentNavigationController(animated: true)
        }
    }
    
    func securityInfoViewController(fromSettings: Bool = false, fromHomeScreen: Bool = false) {
        let controller = SecurityInfoViewController()
        controller.fromSettings = fromSettings
        controller.fromHomeScreen = fromHomeScreen
        navigationController?.pushViewController(controller, animated: true)
    }
    
    var loginWithGooglePopup: LoginWithGooglePopup {
        let controller = LoginWithGooglePopup()
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        return controller
    }
    
    func loginWithGoogle(user: AppleGoogleUser) -> UIViewController {
        let initializer = LoginModuleInitializer()
        let loginController = LoginViewController(nibName: "LoginViewController",
                                                  bundle: nil)
        initializer.loginViewController = loginController
        initializer.setupVC(with: user)
 
        return loginController
    }
    
    func registerWithGoogle(user: AppleGoogleUser) -> UIViewController {
        let initializer = RegistrationModuleInitializer()
        let registerController = RegistrationViewController(nibName: "RegistrationScreen",
                                                            bundle: nil)
        initializer.registrationViewController = registerController
        initializer.setupVC(with: user)
 
        return registerController
    }
    
    func loginWithHeaders(user: AppleGoogleUser, headers: [String:Any]) -> UIViewController {
        let initializer = LoginModuleInitializer()
        let loginController = LoginViewController(nibName: "LoginViewController",
                                                  bundle: nil)
        initializer.loginViewController = loginController
        initializer.setupVC(with: user, headers: headers)
 
        return loginController
    }
    
    func messageAndButtonPopup(with message: String, buttonTitle: String) -> MessageAndButtonPopup {
        let controller = MessageAndButtonPopup()
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.message = message
        controller.buttonTitle = buttonTitle
        
        return controller
    }
    
    func passwordEnterPopup(with appleGoogleUser: AppleGoogleUser, disconnectAppleGoogleLogin: Bool? = nil) -> PasswordEnterPopup {
        let controller = PasswordEnterPopup()
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.appleGoogleUser = appleGoogleUser
        controller.disconnectAppleGoogleLogin = disconnectAppleGoogleLogin
        
        return controller
    }
    
    func appleGoogleUpdatePasswordPopup() -> AppleGoogleUpdatePasswordPopup {
        let controller = AppleGoogleUpdatePasswordPopup()
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        return controller
    }
    
    func securityInfoWarningPopup(errorMessage: String, warningType: SecurityPopupWarningType) -> SecurityInfoWarningPopup {
        let controller = SecurityInfoWarningPopup()
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.errorMessage = errorMessage
        controller.warningType = warningType
        
        return controller
    }
    
    func bottomInfoBanner(text: String) -> BottomInfoBanner {
        let controller = BottomInfoBanner(infoText: text)
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        return controller
    }
    
    
    func paycellDetailPopup(with model: PaycellDetailModel, type: PaycellDetailType) -> PaycellDetailPopup {
        let controller = PaycellDetailPopup()
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.detailType = type
        controller.model = model
        
        return controller
    }
}
