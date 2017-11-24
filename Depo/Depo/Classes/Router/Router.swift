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
    
    let splitContr = SplitIpadViewContoller()
    
    var rootViewController: UIViewController? {
        guard let window = UIApplication.shared.keyWindow,
            let rootviewController = window.rootViewController
            else {
                return nil
        }
        return rootviewController
    }
    
    // MARK: Navigation controller
    
    var navigationController: UINavigationController? {
        get {
            if let navController = rootViewController as? UINavigationController {
                return navController
            }else{
                if let n = rootViewController as? TabBarViewController {
                    return n.activeNavigationController
                }
            }
            return nil
        }
    }
    
    var tabBarVC:UINavigationController? {
        if let nav = navigationController,
            let top = nav.topViewController {
            if let n = top as? TabBarViewController {
                return n.activeNavigationController
            }
            if let n = rootViewController as? TabBarViewController {
                return n.activeNavigationController
            }
        }else{
            if let n = rootViewController as? TabBarViewController {
                return n.activeNavigationController
            }
        }
        
        return nil 
    }
    
    func createRootNavigationController(controller: UIViewController) -> UINavigationController {
        
        let navController = UINavigationController(rootViewController: controller)
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
    
    func pushViewControllertoTableViewNavBar(viewController: UIViewController) {
        if let tabBarVc = tabBarVC {
            
            tabBarVc.pushViewController(viewController, animated: true)
            return
        }
    }
    
    func popViewControllerFromTableViewNavBar(){
        if let tabBarVc = tabBarVC {
            tabBarVc.popViewController(animated: true)
            return
        }
    }
    
    func pushViewController(viewController: UIViewController) {
        let notificationName = NSNotification.Name(rawValue: TabBarViewController.notificationHideTabBar)
        NotificationCenter.default.post(name: notificationName, object: nil)
        
        navigationController?.pushViewController(viewController, animated: true)
        viewController.navigationController?.isNavigationBarHidden = false
        
    }
    
    func pushViewControllerWithoutAnimation(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: false)
        viewController.navigationController?.isNavigationBarHidden = false
    }
    
    func popToRootViewController(){
        navigationController?.popToRootViewController(animated: true)
    }
    
    func popViewController(){
        navigationController?.popViewController(animated: true)
    }
    
    func popCreateStory() {
        if let viewControllers = navigationController?.viewControllers {
            let index = viewControllers.index(where: ({ (viewController) -> Bool in
                return viewController is CreateStoryPhotoSelectionViewController
            }))
            
            if let ind = index, ind > 0 {
                let viewController = viewControllers[ind - 1]
                navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
    
    func presentViewController(controller: UIViewController){
        if let lastViewController = navigationController?.viewControllers.last{
            if controller.popoverPresentationController?.sourceView == nil,
                controller.popoverPresentationController?.barButtonItem == nil {
                controller.popoverPresentationController?.sourceView = lastViewController.view
            }
            lastViewController.present(controller, animated: true, completion: {
            
            })
        }
    }
    
    func pushToCustomNavController(customNavController: UINavigationController?, pushedController: UIViewController) {
        var activeNavController: UINavigationController?
        
        if customNavController == nil {
            activeNavController = navigationController
        } else {
            activeNavController = customNavController
        }
        activeNavController?.pushViewController(pushedController, animated: true)
    }
    
    func presentOnCustomViewController(customNavController: UINavigationController?, presentedController: UIViewController) {
        var activeNavController: UINavigationController?
        
        if customNavController == nil {
            activeNavController = navigationController
        } else {
            activeNavController = customNavController
        }
        activeNavController?.present(presentedController, animated: true, completion: {})
    }
    
    func isOnFavoritesView() -> Bool {
        if let tabBarVc = tabBarVC {
            if let contr = tabBarVc.viewControllers.last as? BaseFilesGreedViewController{
                return contr.isFavorites
            }
        }
        
        return false
    }
    
    //MARK: Splash
    
    var splash: UIViewController?{
        let controller = SplashModuleInitializer.initializeViewController(with: "SplashViewController")
        return controller
    }

    
    //MARK: Onboarding
    
    var onboardingScreen: UIViewController? {
        let conf = IntroduceModuleInitializer()
        let viewController = IntroduceViewController(nibName: "IntroduceViewController",
                                                     bundle: nil)
        conf.introduceViewController = viewController
        conf.setupVC()
        
        return createRootNavigationController(controller: viewController)
    }
    
    
    //MARK: Registartion
    var registrationScreen: UIViewController? {
        let inicializer = RegistrationModuleInitializer()
        let registerController = RegistrationViewController(nibName: "RegistrationScreen",
                                                            bundle:nil)
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
    
    func phoneVereficationScreen(withSignUpSuccessResponse: SignUpSuccessResponse, userInfo: RegistrationUserInfoModel) -> UIViewController {
        
        let inicializer = PhoneVereficationModuleInitializer()
        let controller = PhoneVereficationViewController(nibName: "PhoneVereficationScreen",
                                                         bundle: nil)
        inicializer.phonevereficationViewController = controller
        inicializer.setupConfig(with: withSignUpSuccessResponse, userInfo: userInfo)
        return controller
    }
    
    //MARK: SyncContacts
    
    var syncContacts: UIViewController? {
        let viewController = SyncContactsModuleInitializer.initializeViewController(with: "SyncContactsViewController")
        return viewController
        
    }
    
    //MARK: Terms
    
    func termsAndServicesScreen(login: Bool, delegate: RegistrationViewDelegate? = nil) -> UIViewController {
        let conf = TermsAndServicesModuleInitializer(delegate: delegate)
        let viewController =  TermsAndServicesViewController(nibName: "TermsAndServicesScreen",
                                                             bundle: nil)
        
        conf.setupConfig(withViewController: viewController, fromLogin: login)
        return viewController
    }
    
    
    //MARK: SynchronyseSettings
    
    var synchronyseScreen: UIViewController? {
        
        let inicializer = AutoSyncModuleInitializer()
        let controller = AutoSyncViewController(nibName: "AutoSyncViewController", bundle: nil)
        inicializer.autosyncViewController = controller
        inicializer.setupVC()
        return controller
    }
    
    
    //MARK: Capcha
    
    var capcha: UIViewController? {
        return CaptchaViewController.initFromXib()
    }
    
    
    //MARK: TabBar
    
    var tabBarScreen: UIViewController? {
        let controller = TabBarViewController(nibName: "TabBarView", bundle: nil)
        return controller
    }
    
    
    //MARK: Home Page
    var homePageScreen: UIViewController? {
        if (!SingletonStorage.shared().isAppraterInited) {
            AppRater.sharedInstance().daysUntilPrompt = 0
            AppRater.sharedInstance().launchesUntilPrompt = 10
            AppRater.sharedInstance().remindMeDaysUntilPrompt = 0
            AppRater.sharedInstance().remindMeLaunchesUntilPrompt = 10
            AppRater.sharedInstance().appLaunched()
            
            SingletonStorage.shared().isAppraterInited = true
        }
        
        let controller = HomePageModuleInitializer.initializeViewController(with: "HomePage")
        return controller
    }
    
    
    //MARK: Photos and Videos
    
    var photosAndVideos: UIViewController? {
        let controller = BaseFilesGreedModuleInitializer.initializePhotoVideosViewController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    
    //MARK: Music
    
    var musics: UIViewController? {
  
        let controller = BaseFilesGreedModuleInitializer.initializeMusicViewController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    
    // MARK: All Files
    
    var allFiles: UIViewController?{
    
        let controller = BaseFilesGreedModuleInitializer.initializeAllFilesViewController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    
    // MARK: Favorites
    
    var favorites: UIViewController?{

        let controller = BaseFilesGreedModuleInitializer.initializeFavoritesViewController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    
    // MARK: Folder
    
    func filesFromFolder(folder: Item) -> UIViewController{
        let controller = BaseFilesGreedModuleInitializer.initializeFilesFromFolderViewController(with: "BaseFilesGreedViewController", folder: folder)
        return controller
    }
    
    
    // MARK: User profile
    
    func userProfile(userInfo: AccountInfoResponse) -> UIViewController{
        let viewController = UserProfileModuleInitializer.initializeViewController(with: "UserProfileViewController", userInfo: userInfo)
        return viewController
    }
    
    
    // MARK: File info
    
    var fileInfo: UIViewController?{
        let viewController = FileInfoModuleInitializer.initializeViewController(with: "FileInfoViewController")
        return viewController
    }
    
    
    //MARK: Documents
    
    var documents: UIViewController? {
        let controller = BaseFilesGreedModuleInitializer.initializeDocumentsViewController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    
    // MARK: Create Folder
    
    func createNewFolder(rootFolderID: String?, isFavorites: Bool = false) -> UIViewController{
        let controller = SelectNameModuleInitializer.initializeViewController(with: "SelectNameViewController", viewType: .selectFolderName, rootFolderID: rootFolderID, isFavorites: isFavorites)
        return controller
    }
    
    
    // MARK: Create Album
    
    func createNewAlbum()-> UIViewController{
        let controller = SelectNameModuleInitializer.initializeViewController(with: "SelectNameViewController", viewType: .selectAlbumName)
        return controller
    }
    
    //MARK: CreateStory name
    
    func createStoryName(items: [BaseDataSourceItem]? = nil) {
        let controller = CreateStoryNameModuleInitializer.initializeViewController(with: "CreateStoryNameViewController")
        controller.output.items = items
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        UIApplication.topController()?.present(controller, animated: true, completion: nil)
    }
    
    // MARK: - SearchView
    
    func searchView(output: SearchModuleOutput? = nil) -> UIViewController {
        let controller = SearchViewInitializer.initializeAllFilesViewController(with: "SearchView", output: output)
        return controller
    }
    
    
    //MARK: CreateStory photos selection
    
    func photoSelection(forStory story:PhotoStory) -> UIViewController {
        let controller = CreateStoryModuleInitializer.initializePhotoSelectionViewControllerForStory(with: "BaseFilesGreedViewController", story: story)
        return controller
    }
    
    
    //MARK: CreateStory audio selection
    
    func audioSelection(forStory story:PhotoStory) -> UIViewController {
        let controller = CreateStoryModuleInitializer.initializeAudioSelectionViewControllerForStory(with: "BaseFilesGreedViewController", story: story)
        return controller
    }
    
    
    //MARK: CreateStory photos order 
    
    func photosOrder(forStory story: PhotoStory) -> UIViewController {
        let controller = CreateStoryPhotosOrderModuleInitializer.initializeViewController(with: "CreateStoryPhotosOrderViewController", story: story)
        return controller
    }
    
    //MARK: CreateStory preview
    
    func storyPreview(forStory story: PhotoStory, responce: CreateStoryResponce) -> UIViewController {
        let controller = CreateStoryPreviewModuleInitializer.initializePreviewViewControllerForStory(with: "CreateStoryPreviewViewController",
                                                                                                   story: story,
                                                                                                   responce: responce)
        return controller
    }
    
    //MARK: Upload All files
    
    func uploadAllFiles(searchService: RemoteItemsService) -> UIViewController {
        let controller = UploadFilesSelectionModuleInitializer.initializeViewController(with: "BaseFilesGreedViewController", searchService: searchService)
        return controller
    }
    
    //MARK: Upload All files
    
    func uploadPhotos() -> UIViewController {
        let controller = UploadFilesSelectionModuleInitializer.initializeUploadPhotosViewController()
        //UploadFilesSelectionModuleInitializer.initializeViewController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    func uploadPhotos(rootUUID: String) -> UIViewController {
        let controller = UploadFilesSelectionModuleInitializer.initializeUploadPhotosViewController(rootUUID: rootUUID)
        //UploadFilesSelectionModuleInitializer.initializeViewController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    //MARK: Select Folder view controller
    
    func selectFolder(folder: Item?) -> SelectFolderViewController {
        let controller = SelectFolderModuleInitializer.initializeSelectFolderViewController(with: "BaseFilesGreedViewController", folder: folder)
        return controller
    }
    
    func filesDetailViewController(fileObject:WrapData, from items:[[WrapData]]) -> UIViewController {
        let controller = PhotoVideoDetailModuleInitializer.initializeViewController(with: "PhotoVideoDetailViewController")
        let c = controller as! PhotoVideoDetailViewController
        c.interactor!.onSelectItem(fileObject: fileObject, from: items)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        return c
    }
    
    //MARK: Albums list
    
    func albumsListController() -> BaseFilesGreedChildrenViewController {
        let controller = AlbumsModuleInitializer.initializeAlbumsController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    //MARK: Adding photos to album
    
    func addPhotosToAlbum(photos: [BaseDataSourceItem]) -> AlbumSelectionViewController {
        let controller = AlbumsModuleInitializer.initializeSelectAlbumsController(with: "BaseFilesGreedViewController", photos: photos)
        return controller
    }
    
    //MARK: Album detail
    
    func albumDetailController(album: AlbumItem) -> AlbumDetailViewController{
        let controller = AlbumDetailModuleInitializer.initializeAlbumDetailController(with: "BaseFilesGreedViewController", album: album)
        return controller
    }
    
    //MARK: Free App Space
    
    func freeAppSpace() -> UIViewController{
        let controller = FreeAppSpaceModuleInitializer.initializeFreeAppSpaceViewController(with: "FreeAppSpaceViewCotroller")
        return controller
    }
    
    // MARK: SETTINGS
    
    var settings: UIViewController? {
        let controller = SettingsModuleInitializer.initializeViewController(with: "SettingsViewController")
        return controller
    }
    
    var settingsIpad: UIViewController? {
        let leftController = settings
        let rightController = syncContacts
        
        //let splitContr = SplitIpadViewContoller()
        splitContr.configurateWithControllers(leftViewController: leftController as! SettingsViewController, controllers: [rightController!])
        
        let containerController = EmptyContainerNavVC.setupContainer(withSubVC: splitContr.getSplitVC())
        return containerController
    }
    

    // MARK: Help and support
    
    var helpAndSupport: UIViewController? {
        let controller = HelpAndSupportModuleInitializer.initializeViewController(with: "HelpAndSupportViewController")
        return controller
    }
    
    // MARK: Auto Upload
    
    var autoUpload: UIViewController {
        let controller = AutoSyncModuleInitializer.initializeViewController(with: "AutoSyncViewController", fromSettings: true)
        return controller
    }
    
    // MARK: - Import photos
    
    var importPhotos: UIViewController? {
        let controller = ImportPhotosInitializer.initializeViewController(with: "ImportPhotosViewController")
        return controller
    }
    
    // MARK: - Import photos
    
    var usageInfo: UIViewController? {
        let controller = UsageInfoInitializer.initializeViewController(with: "UsageInfoViewController")
        return controller
    }
    
    var instagramAuth: UIViewController {
        return InstagramAuthViewController()
    }
    
    // MARK: OTP
    
    func otpView(responce: SignUpSuccessResponse, userInfo: AccountInfoResponse, phoneNumber: String) -> UIViewController {
        let controller = OTPViewModuleInitializer.viewController(responce: responce, userInfo: userInfo, phoneNumber: phoneNumber)
        return controller
    }
    
    // MARK: feedback subView
    
    func showFeedbackSubView(){
        let controller = FeedbackViewModuleInitializer.initializeViewController(with: "FeedbackViewController")
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        UIApplication.topController()?.present(controller, animated: true, completion: nil)
    }
    
    @objc func vcForCurrentState() -> UIViewController? {
        return splash
    }
    
    // MARK: - Activity Timeline
    
    var vcActivityTimeline: UIViewController {
        return ActivityTimelineModuleInitializer.initialize(ActivityTimelineViewController.self)
    }
    

    
    //MARK: FreeAppSpace
    
    func showFreeAppSpace(){
        let controller = freeAppSpace()
        pushViewController(viewController: controller)
    }
    // MARK: - Packages
    
    var packages: UIViewController {
        return PackagesModuleInitializer.viewController
    }
    
    // MARK: - Passcode
    
    func passcodeSettings() -> UIViewController {
        return PasscodeSettingsModuleInitializer.viewController
    }
}
