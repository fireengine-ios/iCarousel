//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderRouter.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPhotosOrderRouter: CreateStoryPhotosOrderRouterInput {

    func goToMain(){
        let router = RouterVC()
        router.popToRootViewController()
    }
    
    func goToMusicSelection(story: PhotoStory, navigationController: UINavigationController?){
        let router = RouterVC()
        let controller = router.audioSelection(forStory: story)
        let navigation = UINavigationController(rootViewController: controller)
        
        navigation.navigationBar.isHidden = false
        router.presentViewController(controller: navigation)
    }
    
    func goToStoryPreviewViewController(forStory story: PhotoStory, responce: CreateStoryResponce, navigationController: UINavigationController?){
        guard let nController = navigationController else{
            return
        }
        let router = RouterVC()
        let controller = router.storyPreview(forStory: story, responce: responce)
        
        nController.pushViewController(controller, animated: true)
    }
    
}
