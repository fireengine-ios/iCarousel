//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderRouterInput.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol CreateStoryPhotosOrderRouterInput {
    func goToMain()
    
    func goToMusicSelection(story: PhotoStory, navigationController: UINavigationController?)
    
    func goToStoryPreviewViewController(forStory story: PhotoStory, responce: CreateStoryResponce, navigationController: UINavigationController?)
    
    func showMusicEmptyPopUp(okHandler: @escaping VoidHandler)
}
