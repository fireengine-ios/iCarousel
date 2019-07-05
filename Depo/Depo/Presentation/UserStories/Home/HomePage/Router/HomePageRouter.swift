//
//  HomePageHomePageRouter.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class HomePageRouter: HomePageRouterInput {
    
    private let router = RouterVC()
    weak var presenter: HomePagePresenter!
    
    func moveToSettingsScreen() {
        var controller: UIViewController?
        if (Device.isIpad) {
            controller = router.settingsIpad
        } else {
            controller = router.settings
        }
        
        router.pushViewController(viewController: controller!)
    }

    func moveToSyncContacts() {
        
        var controller: UIViewController?
        
        if (Device.isIpad) {
            controller = router.settingsIpad
        } else {
            controller = router.syncContacts
        }
        
        router.pushViewController(viewController: controller!)
//        router.tabBarVC?.pushViewController(controller!, animated: true)
    }
    
    func moveToAllFilesPage() {
        let allFiles = router.allFiles(moduleOutput: presenter, sortType: presenter.allFilesSortType, viewType: presenter.allFilesViewType)
        router.pushViewController(viewController: allFiles)
    }
    
    func moveToFavouritsFilesPage() {
        let favourites = router.favorites(moduleOutput: presenter, sortType: presenter.favoritesSortType, viewType: presenter.favoritesViewType)
        router.pushViewController(viewController: favourites)
    }
    
    func moveToCreationStory() {
        let controller = router.createStory(navTitle: TextConstants.createStory)
        router.pushViewController(viewController: controller)
    }
    
    func moveToSearchScreen(output: UIViewController?) {
        let controller = router.searchView(navigationController: output?.navigationController, output: output as? SearchModuleOutput)
        router.pushViewController(viewController: controller)
    }
    
    func showError(errorMessage: String) {
        UIApplication.showErrorAlert(message: errorMessage)
    }
    
    func showPopupForNewUser(with message: String, title: String, headerTitle: String, completion: VoidHandler?) {
        let controller = PopUpController.with(title: nil,
                                              message: message,
                                              image: .none,
                                              firstButtonTitle: TextConstants.noForUpgrade,
                                              secondButtonTitle: TextConstants.yesForUpgrade,
                                               secondAction: { [weak self] vc in
                                                vc.dismiss(animated: true, completion: {
                                                    self?.moveToPremium(title: title, headerTitle: headerTitle, completion: completion)
                                                })
        })
        
        UIApplication.topController()?.present(controller, animated: true, completion: nil)
    }
    
    // MARK: Utility methods
    private func moveToPremium(title: String, headerTitle: String, completion: VoidHandler?) {
        let controller = router.premium(title: title, headerTitle: headerTitle)
        /// Show another popup after the transition because the user did not see it behind it
        let isPresentedQuotaPopUpUnderPremiumPopUp = router.getViewControllerForPresent()?.presentedViewController is LargeFullOfQuotaPopUp
        if isPresentedQuotaPopUpUnderPremiumPopUp {
            completion?()
            router.getViewControllerForPresent()?.dismiss(animated: false, completion: { [weak self] in
                self?.router.pushViewController(viewController: controller)
            })
        } else {
            router.pushViewController(viewController: controller)
        }
    }
    
}
