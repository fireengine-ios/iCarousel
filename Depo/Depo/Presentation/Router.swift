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
    
    func getFloatingButtonsArray() -> [FloatingButtonsType]{
        let nController = navigationController
        let viewController = nController?.viewControllers.last
        
        if let baseViewController = viewController as? BaseViewController{
            return baseViewController.floatingButtonsArray
        }
        
        return [FloatingButtonsType]()
    }
    
    func getParentUUID() -> String{
        
        if let viewController = navigationController?.viewControllers.last as? BaseViewController{
            return viewController.parentUUID
        }
        
        return ""
    }
    
    func isRootViewControllerAlbumDetail() -> Bool{
        return navigationController?.viewControllers.last is AlbumDetailViewController
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
    
    func popToRootViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    func popCreateStory() {
        if let viewControllers = navigationController?.viewControllers {
            var index: Int? = nil
            
            for (i, viewController) in viewControllers.enumerated(){
                if viewController is CreateStoryPhotoSelectionViewController
                    || viewController is CreateStoryPhotosOrderViewController{
                    index = i
                    break
                }
            }

            if let ind = index{
                let viewController = viewControllers[ind - 1]
                navigationController?.popToViewController(viewController, animated: true)
            }else{
                navigationController?.popToRootViewController(animated: true)
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
    
    var syncContacts: UIViewController {
        let viewController = SyncContactsModuleInitializer.initializeViewController(with: "SyncContactsViewController")
        return viewController
    }
    
    func manageContacts(moduleOutput: ManageContactsModuleOutput?) -> UIViewController {
        let viewController = ManageContactsModuleInitializer.initializeViewController(with: "ManageContactsViewController", moduleOutput: moduleOutput)
        return viewController
    }
    
    func duplicatedContacts(analyzeResponse: [ContactSync.AnalyzedContact], moduleOutput: DuplicatedContactsModuleOutput?) -> UIViewController {
        let viewController = DuplicatedContactsModuleInitializer.initializeViewController(with: "DuplicatedContactsViewController",
                                                                                          analyzeResponse: analyzeResponse,
                                                                                          moduleOutput: moduleOutput)
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
    
    
    //MARK: Photos and Videos
    
    var photosScreen: UIViewController? {
        let controller = BaseFilesGreedModuleInitializer.initializePhotoVideosViewController(with: "BaseFilesGreedViewController", screenFilterType: .Photo)
        return controller
    }
    
    var videosScreen: UIViewController? {
        let controller = BaseFilesGreedModuleInitializer.initializePhotoVideosViewController(with: "BaseFilesGreedViewController", screenFilterType: .Video)
        return controller
    }
    
    //MARK: Music
    
    var musics: UIViewController? {
  
        let controller = BaseFilesGreedModuleInitializer.initializeMusicViewController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    
    // MARK: All Files
    
    func allFiles(moduleOutput: BaseFilesGreedModuleOutput?, sortType: MoreActionsConfig.SortRullesType, viewType: MoreActionsConfig.ViewType) -> UIViewController? {
        let controller = BaseFilesGreedModuleInitializer.initializeAllFilesViewController(with: "BaseFilesGreedViewController",
                                                                                          moduleOutput: moduleOutput,
                                                                                          sortType: sortType,
                                                                                          viewType: viewType)
        return controller
    }
    
    
    // MARK: Favorites
    
    func favorites(moduleOutput: BaseFilesGreedModuleOutput?, sortType: MoreActionsConfig.SortRullesType, viewType: MoreActionsConfig.ViewType) -> UIViewController? {
        let controller = BaseFilesGreedModuleInitializer.initializeFavoritesViewController(with: "BaseFilesGreedViewController",
                                                                                           moduleOutput: moduleOutput,
                                                                                           sortType: sortType,
                                                                                           viewType: viewType)
        return controller
    }
    
    
    // MARK: Folder
    
    func filesFromFolder(folder: Item, type: MoreActionsConfig.ViewType, sortType: MoreActionsConfig.SortRullesType, moduleOutput: BaseFilesGreedModuleOutput?, alertSheetExcludeTypes: [ElementTypes]? = nil) -> UIViewController{
        let controller = BaseFilesGreedModuleInitializer.initializeFilesFromFolderViewController(with: "BaseFilesGreedViewController",
                                                                                                 folder: folder,
                                                                                                 type: type,
                                                                                                 sortType: sortType,
                                                                                                 moduleOutput: moduleOutput,
                                                                                                 alertSheetExcludeTypes: alertSheetExcludeTypes)

        return controller
    }
    
    
    // MARK: User profile
    
    func userProfile(userInfo: AccountInfoResponse, isTurkcellUser: Bool = false) -> UIViewController{
        let viewController = UserProfileModuleInitializer.initializeViewController(with: "UserProfileViewController", userInfo: userInfo, isTurkcellUser: isTurkcellUser)
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
    
    func createStoryName(items: [BaseDataSourceItem]? = nil, needSelectionItems: Bool = false, isFavorites: Bool = false) {
        let controller = CreateStoryNameModuleInitializer.initializeViewController(with: "CreateStoryNameViewController", needSelectionItems: needSelectionItems, isFavorites: isFavorites)
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
    
    func favoritePhotoSelection(forStory story:PhotoStory) -> UIViewController {
        let controller = CreateStoryModuleInitializer.initializeFavoritePhotoSelectionViewControllerForStory(with: "BaseFilesGreedViewController", story: story)
        return controller
    }
    
    
    //MARK: CreateStory audio selection
    
    func audioSelection(forStory story:PhotoStory) -> UIViewController {
        let controller = CreateStoryModuleInitializer.initializeAudioSelectionViewControllerForStory(with: "CreateStoryAudioSelectionViewController", story: story)
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
    
    func uploadPhotos() -> UIViewController {
        let controller = LocalAlbumModuleInitializer.initializeLocalAlbumsController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    func uploadPhotos(rootUUID: String) -> UIViewController {
        let controller = UploadFilesSelectionModuleInitializer.initializeUploadPhotosViewController(rootUUID: rootUUID)
        return controller
    }
    
    func uploadFromLifeBox(folderUUID: String, soorceUUID: String = "", sortRule: SortedRules = .timeUp) -> UIViewController {
        if isRootViewControllerAlbumDetail() {
            let controller = UploadFromLifeBoxModuleInitializer.initializePhotoVideosViewController(with: "BaseFilesGreedViewController", albumUUID: folderUUID)
            return controller
        } else {
            let controller = UploadFromLifeBoxModuleInitializer.initializeFilesForFolderViewController(with: "BaseFilesGreedViewController",
                                                                                                       destinationFolderUUID: folderUUID,
                                                                                                       outputFolderUUID: soorceUUID,
                                                                                                       sortRule: sortRule)
            return controller
        }
    }
    
    //MARK: Select Folder view controller
    
    func selectFolder(folder: Item?, sortRule: SortedRules = .timeUp) -> SelectFolderViewController {
        let controller = SelectFolderModuleInitializer.initializeSelectFolderViewController(with: "BaseFilesGreedViewController",
                                                                                            folder: folder,
                                                                                            sortRule: sortRule)
        return controller
    }
    
    func filesDetailViewController(fileObject: WrapData, items: [WrapData]) -> UIViewController {
        let controller = PhotoVideoDetailModuleInitializer.initializeViewController(with: "PhotoVideoDetailViewController",
                                                                                    selectedItem: fileObject,
                                                                                    allItems: items)
        let c = controller as! PhotoVideoDetailViewController
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        return c
    }
    
    func filesDetailAlbumViewController(fileObject: WrapData, items: [WrapData], albumUUID: String) -> UIViewController {
        let controller = PhotoVideoDetailModuleInitializer.initializeAlbumViewController(with: "PhotoVideoDetailViewController",
                                                                                         selectedItem: fileObject,
                                                                                         allItems: items,
                                                                                         albumUUID: albumUUID)
        let c = controller as! PhotoVideoDetailViewController
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
    
    func albumDetailController(album: AlbumItem, type: MoreActionsConfig.ViewType, moduleOutput: BaseFilesGreedModuleOutput?) -> AlbumDetailViewController{
        let controller = AlbumDetailModuleInitializer.initializeAlbumDetailController(with: "BaseFilesGreedViewController", album: album, type: type, moduleOutput: moduleOutput)
        return controller
    }
    
    //MARK: Stories list
    
    func storiesListController() -> BaseFilesGreedChildrenViewController {
        let controller = StoriesInitializer.initializeStoriesController(with: "BaseFilesGreedViewController")
        return controller
    }
    
    //MARK: People list
    
    func peopleListController() -> BaseFilesGreedChildrenViewController {
        let controller = FaceImageItemsInitializer.initializePeopleController(with: "BaseFilesGreedViewController")
        return controller as! BaseFilesGreedChildrenViewController
    }
    
    //MARK: Thing list
    
    func thingsListController() -> BaseFilesGreedChildrenViewController {
        let controller = FaceImageItemsInitializer.initializeThingsController(with: "BaseFilesGreedViewController")
        return controller as! BaseFilesGreedChildrenViewController
    }
    
    //MARK: Place list
    
    func placesListController() -> BaseFilesGreedChildrenViewController {
        let controller = FaceImageItemsInitializer.initializePlacesController(with: "BaseFilesGreedViewController")
        return controller as! BaseFilesGreedChildrenViewController
    }
    
    //MARK: Face Image Recognition Photos
    
    func imageFacePhotosController(albumUUID: String, item: Item, coverPhotoURL: URL, moduleOutput: FaceImageItemsModuleOutput?) -> BaseFilesGreedChildrenViewController {
        let controller = FaceImagePhotosInitializer.initializeController(with: "FaceImagePhotosViewController",
                                                                         albumUUID: albumUUID,
                                                                         item: item,
                                                                         coverPhotoURL: coverPhotoURL,
                                                                         moduleOutput: moduleOutput)
        return controller as! BaseFilesGreedChildrenViewController
    }
    
    func faceImageChangeCoverController(albumUUID: String, moduleOutput: FaceImageChangeCoverModuleOutput?)  -> BaseFilesGreedChildrenViewController {
        let controller = FaceImageChangeCoverInitializer.initializeController(with: "BaseFilesGreedViewController", albumUUID: albumUUID, moduleOutput: moduleOutput)
        return controller as! BaseFilesGreedChildrenViewController
    }
    
    //MARK: Free App Space
    
    func freeAppSpace() -> UIViewController{
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
        
        //let splitContr = SplitIpadViewContoller()
        splitContr.configurateWithControllers(leftViewController: leftController as! SettingsViewController, controllers: [rightController])
        
        let containerController = EmptyContainerNavVC.setupContainer(withSubVC: splitContr.getSplitVC())
        return containerController
    }
    

    // MARK: Help and support
    
    var helpAndSupport: UIViewController? {
        let controller = HelpAndSupportModuleInitializer.initializeViewController(with: "HelpAndSupportViewController")
        return controller
    }
    
    // MARK: Turkcell Security
    
    var turkcellSecurity: UIViewController {
        return TurkcellSecurityModuleInitializer.viewController
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
    
    // MARK: Face image
    
    var faceImage: UIViewController {
        let controller = FaceImageInitializer.initializeViewController(with: "FaceImageViewController")
        return controller
    }
    
    // MARK: Face image add name
    
    func faceImageAddName(_ item: WrapData, moduleOutput: FaceImagePhotosModuleOutput?) -> UIViewController {
    let controller = FaceImageAddNameInitializer.initializeViewController(with: "FaceImageAddNameViewController", item: item, moduleOutput: moduleOutput)
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
    
    func passcodeSettings(isTurkcell: Bool, inNeedOfMail: Bool) -> UIViewController {
        return PasscodeSettingsModuleInitializer.setupModule(isTurkcell: isTurkcell, inNeedOfMail: inNeedOfMail)
    }
}
