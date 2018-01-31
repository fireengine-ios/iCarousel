//
//  CreateStoryNameCreateStoryNameRouterInput.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryNameRouterInput {
    
    func goToSelectionPhotosForStory(story: PhotoStory)
    
    func goToFavoriteSelectionPhotosForStory(story: PhotoStory)
    
    func goToPhotosOrderForStory(story: PhotoStory)
    
}
