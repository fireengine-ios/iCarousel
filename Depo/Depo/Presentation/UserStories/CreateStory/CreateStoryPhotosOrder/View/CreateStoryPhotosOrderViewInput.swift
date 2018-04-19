//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderViewInput.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol CreateStoryPhotosOrderViewInput: class, ErrorPresenter {
    func setupInitialState()
    func showStory(story: PhotoStory)
    func getNavigationControllet() -> UINavigationController?
}
