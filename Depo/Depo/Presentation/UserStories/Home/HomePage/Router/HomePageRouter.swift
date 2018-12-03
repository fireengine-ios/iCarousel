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
        let allFiles = router.allFiles(moduleOutput: presenter, sortType: presenter.allFilesSortType, viewType: presenter.allFilesViewType)!
        router.pushViewController(viewController: allFiles)
    }
    
    func moveToFavouritsFilesPage() {
        let favourites = router.favorites(moduleOutput: presenter, sortType: presenter.favoritesSortType, viewType: presenter.favoritesViewType)!
        router.pushViewController(viewController: favourites)
    }
    
    func moveToCreationStory() {
        router.createStoryName()
    }
    
    func moveToSearchScreen(output: UIViewController?) {
        let controller = router.searchView(output: output as? SearchModuleOutput)
        output?.navigationController?.delegate = controller as? BaseViewController
        controller.transitioningDelegate = output as? UIViewControllerTransitioningDelegate
        router.pushViewController(viewController: controller)
    }
    
    func showError(errorMessage: String) {
        UIApplication.showErrorAlert(message: errorMessage)
    }
}
