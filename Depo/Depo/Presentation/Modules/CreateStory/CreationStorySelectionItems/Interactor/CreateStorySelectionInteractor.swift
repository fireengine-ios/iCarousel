//
//  CreateStorySelectionInteractor.swift
//  Depo
//
//  Created by Oleg on 02/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStorySelectionInteractor: BaseFilesGreedInteractor {

    var photoStory: PhotoStory?
    
    override func viewIsReady(){
        guard let story = photoStory else {
            return
        }
        if let out = output as? CreateStorySelectionInteractorOutput{
            out.configurateWithPhotoStory(story: story)
        }
    }

}
