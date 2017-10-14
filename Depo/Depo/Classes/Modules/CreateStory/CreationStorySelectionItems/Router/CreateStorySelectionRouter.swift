//
//  CreateStorySelectionRouter.swift
//  Depo
//
//  Created by Oleg on 02/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStorySelectionRouter:BaseFilesGreedRouter, CreateStoryRouterInput {
    
    func goToSelectionAudioFor(story: PhotoStory){
        let router = RouterVC()
        let controller = router.audioSelection(forStory: story)
        router.pushViewController(viewController: controller)
    }
    
    func goToSelectionOrderPhotosFor(story: PhotoStory){
        let router = RouterVC()
        let controller = router.photosOrder(forStory: story)
        router.pushViewController(viewController: controller)
    }
    
}
