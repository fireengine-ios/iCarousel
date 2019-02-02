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
    private let analyticsManager: AnalyticsService = factory.resolve()
    private lazy var createStoryService = CreateStoryService(transIdLogging: true)
}

// MARK: CreateStoryPreviewInteractorInput
extension CreateStoryPreviewInteractor: CreateStoryPreviewInteractorInput {
    
    func viewIsReady() {
        guard let resp = responce else {
            return
        }
        output?.startShowVideoFromResponce(responce: resp)
        analyticsManager.logScreen(screen: .createStoryPreview)
        analyticsManager.trackDimentionsEveryClickGA(screen: .createStoryPreview)
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
        
        createStoryService.createStory(createStory: parameter, success: { [weak self] in
            DispatchQueue.main.async {
                self?.analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .story, eventLabel: .crateStory(.save))
                self?.output?.storyCreated()
                ItemOperationManager.default.newStoryCreated()
            }
            
        }, fail: {[weak self] error in
            DispatchQueue.main.async {
                self?.output?.storyCreatedWithError()
                self?.isRequestStarted = false
            }
        })
    }
    
}
