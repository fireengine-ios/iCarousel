//
//  CreateStoryPreviewCreateStoryPreviyInteractor.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPreviewInteractor {
    weak var output: CreateStoryPreviewInteractorOutput?
    var story: PhotoStory?
    var responce: CreateStoryResponce?
    var isRequestStarted = false
}

// MARK: CreateStoryPreviewInteractorInput
extension CreateStoryPreviewInteractor: CreateStoryPreviewInteractorInput {
    
    func viewIsReady() {
        guard let resp = responce else {
            return
        }
        output?.startShowVideoFromResponce(responce: resp)
    }
    
    func onSaveStory() {
        if isRequestStarted {
            return
        }
        
        guard let story_ = story else {
            return
        }
        
        guard let parameter = story_.photoStoryRequestParameter() else {
            return
        }
        
        isRequestStarted = true
        
        CreateStoryService().createStory(createStory: parameter, success: {[weak self] in
            DispatchQueue.toMain {
                self?.output?.storyCreated()
                ItemOperationManager.default.newStoryCreated()
            }
            
            }, fail: {[weak self] error in
                DispatchQueue.toMain {
                    self?.output?.storyCreatedWithError()
                    self?.isRequestStarted = false
                }
        })
    }
    
}
