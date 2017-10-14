//
//  CreateStoryNameCreateStoryNameInteractor.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryNameInteractor: CreateStoryNameInteractorInput {

    weak var output: CreateStoryNameInteractorOutput!
    
    func onCreateStory(storyName: String){
        let story = PhotoStory(name: storyName)
        output.goToSelectionPhoto(forStory: story)
    }

}
