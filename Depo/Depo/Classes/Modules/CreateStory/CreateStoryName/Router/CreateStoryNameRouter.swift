//
//  CreateStoryNameCreateStoryNameRouter.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryNameRouter: CreateStoryNameRouterInput {
    
    func goToSelectionPhotosForStory(story: PhotoStory) {
        let router = RouterVC()
        let controller = router.photoSelection(forStory: story)
        router.pushViewController(viewController: controller)
    }
    
    func goToPhotosOrderForStory(story: PhotoStory) {
        let router = RouterVC()
        let controller = router.photosOrder(forStory: story)
        router.pushViewController(viewController: controller)
    }
}
