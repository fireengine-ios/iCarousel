//
//  CreateStoryNameCreateStoryNameInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryNameInteractorOutput: class {
    
    func goToSelectionPhoto(forStory story: PhotoStory)
 
    func goToFavoriteSelectionPhoto(forStory story: PhotoStory)

    func goToPhotosOrderForStory(story: PhotoStory)
}
