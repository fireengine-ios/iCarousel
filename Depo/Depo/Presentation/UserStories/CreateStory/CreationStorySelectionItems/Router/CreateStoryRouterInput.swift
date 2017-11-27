//
//  CreateStoryCreateStoryPhotosRouterInput.swift
//  Depo
//
//  Created by Oleg on 02/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryRouterInput {
    
    func goToSelectionAudioFor(story: PhotoStory)
    
    func goToSelectionOrderPhotosFor(story: PhotoStory)
    
}
