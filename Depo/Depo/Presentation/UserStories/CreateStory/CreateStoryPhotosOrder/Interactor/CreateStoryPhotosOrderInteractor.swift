//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderInteractor.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPhotosOrderInteractor: CreateStoryPhotosOrderInteractorInput {

    weak var output: CreateStoryPhotosOrderInteractorOutput!
    
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
        
        
        story.storyPhotos.removeAll()
        story.storyPhotos.append(contentsOf: array)
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
        
        
        //            CreateStoryService().createStory(createStory: parameter_, success: {[weak self] in
        //                let t = CreateStoryPreview(name: parameter_.title, imageuuid: parameter_.imageUUids, musicUUID: parameter_.audioUuid, musicId: parameter_.musicId)
        //                CreateStoryService().getPreview(preview: t, success: {
        //                    if let self_ = self {
        //                        DispatchQueue.main.async {
        //                            self_.output.storyCreated()
        //                        }
        //                    }
        //                }, fail: { (d) in
        //                    if let self_ = self {
        //                        DispatchQueue.main.async {
        //                            self_.output.storyCreatedWithError()
        //                        }
        //                    }
        //                })
        //
        //                }, fail: {[weak self] (error) in
        //                    if let self_ = self {
        //                        DispatchQueue.main.async {
        //                            self_.output.storyCreatedWithError()
        //                        }
        //                    }
        //            })
        
    }
    
    func onMusicSelection() {
        guard let story_ = story else {
            return
        }
        output.goToAudioSelection(story: story_)
    }
    
}
