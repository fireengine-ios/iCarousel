//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderInteractor.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPhotosOrderInteractor: CreateStoryPhotosOrderInteractorInput {

    weak var output: CreateStoryPhotosOrderInteractorOutput!
    
    private lazy var fileService = WrapItemFileService()
    
    var story: PhotoStory?
    
    var isRequestStarted = false

    func viewIsReady() {
        if (story != nil) {
            output.showStory(story: story!)
        }
    }
    
    func onNextButton(array: [Item]) {
        if isRequestStarted {
            return
        }
        
        guard let story = story else {
            return
        }
        
        if story.music == nil {
            output.audioNotSelectedError()
            return
        }
        
        if array.first(where: {$0.isLocalItem}) != nil {
            sync(items: array)
        } else {
            createStory(with: array)
        }
    }
    
    private func createStory(with items: [Item]) {
        guard let story = story else {
            return
        }
        
        output.startCreateStory()
        
        story.storyPhotos.removeAll()
        story.storyPhotos.append(contentsOf: items)
        //TODO: creation story on server
        isRequestStarted = true
        if let parameter = story.photoStoryRequestParameter() {
            let t = CreateStoryPreview(name: parameter.title,
                                       imageuuid: parameter.imageUUids,
                                       musicUUID: parameter.audioUuid,
                                       musicId: parameter.musicId)
            
            CreateStoryService().getPreview(preview: t, success: { [weak self] responce in
                if let `self` = self {
                    self.isRequestStarted = false
                    DispatchQueue.main.async {
                        self.output.goToStoryPreview(story: story, responce: responce)
                    }
                }
                }, fail: { [weak self] fail in
                    if let `self` = self {
                        self.isRequestStarted = false
                        DispatchQueue.main.async {
                            self.output.createdStoryFailed(with: fail)
                        }
                    }
            })
        } else {
            isRequestStarted = false
        }
    }
    
    func onMusicSelection() {
        guard let story_ = story else {
            return
        }
        output.goToAudioSelection(story: story_)
    }
    
    private func sync(items: [Item]) {        
        let operations = fileService.syncItemsIfNeeded(items, success: { [weak self] in
            self?.createStory(with: items)
        }) { [weak self] error in
            DispatchQueue.main.async {
                self?.output.createdStoryFailed(with: error)
            }
        }
        
        if operations != nil, let output = output as? BaseAsyncOperationInteractorOutput {
            output.startCancelableAsync(cancel: { [weak self] in
                DispatchQueue.main.async {
                    self?.output.createdStoryFailed(with: ErrorResponse.string(TextConstants.createStoryCancel))
                }
            })
        }
    }
    
}
