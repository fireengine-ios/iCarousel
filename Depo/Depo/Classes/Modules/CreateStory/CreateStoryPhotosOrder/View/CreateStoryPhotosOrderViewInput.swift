//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderViewInput.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol CreateStoryPhotosOrderViewInput: class {

    /**
        @author Oleg
        Setup initial state of the view
    */

    func setupInitialState()
    
    func showStory(story: PhotoStory)
    
}
