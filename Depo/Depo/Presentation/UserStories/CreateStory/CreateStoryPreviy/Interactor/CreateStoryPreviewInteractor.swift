//
//  CreateStoryPreviewCreateStoryPreviyInteractor.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPreviewInteractor {
    weak var output: CreateStoryPreviewInteractorOutput?
    var story:PhotoStory? = nil
    var responce: CreateStoryResponce? = nil
}

// MARK: CreateStoryPreviewInteractorInput
extension CreateStoryPreviewInteractor: CreateStoryPreviewInteractorInput {
    
    func viewIsReady(){
        guard let resp = responce else {
            return
        }
        output?.startShowVideoFromResponce(responce: resp)
    }
    
    func onSaveStory(){
        guard let story_ = story else {
            return
        }
        
        guard let parameter = story_.photoStoryRequestParameter() else{
            return
        }
        
        CreateStoryService().createStory(createStory: parameter, success: {[weak self] in
            DispatchQueue.main.async {
                self?.output?.storyCreated()
            }
            
            }, fail: {[weak self] (error) in
                DispatchQueue.main.async {
                    self?.output?.storyCreatedWithError()
                }
        })
    }
    
}
