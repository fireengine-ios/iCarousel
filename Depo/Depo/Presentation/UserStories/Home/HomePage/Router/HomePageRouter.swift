//
//  HomePageHomePageRouter.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class HomePageRouter: HomePageRouterInput {
    let router = RouterVC()
    
    func moveToSettingsScreen() {
        var controller: UIViewController?
        if (Device.isIpad){
            controller = router.settingsIpad
        }else{
            controller = router.settings
        }
        
        router.pushViewController(viewController: controller!)
    }

    func moveToSyncContacts() {
        
        var controller: UIViewController?
        
        if (Device.isIpad){
            controller = router.settingsIpad
        }else{
            controller = router.syncContacts
        }
        
        router.pushViewController(viewController: controller!)
//        router.tabBarVC?.pushViewController(controller!, animated: true)
    }
    
    func moveToAllFilesPage() {
        let allFiles = router.allFiles!
        router.pushViewController(viewController: allFiles)
    }
    
    func moveToFavouritsFilesPage() {
        let favourites = router.favorites!
        router.pushViewController(viewController: favourites)
    }
    
    func moveToCreationStory(){
        let router = RouterVC()
        router.createStoryName()
    }
}
