//
//  CreateStoryPreviewCreateStoryPreviewRouter.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPreviewRouter {
    
}

// MARK: CreateStoryPreviewRouterInput
extension CreateStoryPreviewRouter: CreateStoryPreviewRouterInput {
    func goToMain() {
        let router = RouterVC()
        router.popCreateStory()
    }
}
