//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryPhotosOrderInteractorOutput: class {
    
    func showStory(story: PhotoStory)
    
    func storyCreated()
    
    func storyCreatedWithError()
    
}
