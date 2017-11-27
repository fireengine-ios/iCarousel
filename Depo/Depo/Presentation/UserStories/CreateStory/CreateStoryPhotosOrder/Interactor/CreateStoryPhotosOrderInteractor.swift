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

    func viewIsReady(){
        if (story != nil){
            output.showStory(story: story!)
        }
    }
    
    func onNextButton(array: [Item]){
        guard let story_ = story else{
            return
        }
        
        if story_.music == nil{
            output.audioNotSelectedError()
            return
        }
        
        story_.storyPhotos.removeAll()
        story_.storyPhotos.append(contentsOf: array)
        
        //TODO: creation story on server
        
        let parameter = story_.photoStoryRequestParameter()
        if let parameter_ = parameter {
            let t = CreateStoryPreview(name: parameter_.title,
                                       imageuuid: parameter_.imageUUids,
                                       musicUUID: parameter_.audioUuid,
                                       musicId: parameter_.musicId)
            CreateStoryService().getPreview(preview: t, success: { [weak self] (responce) in
                if let self_ = self {
                    DispatchQueue.main.async {
                        self_.output.goToStoryPreview(story: story_, responce: responce)
                    }
                }
            }, fail: { [weak self] (fail) in
                if let self_ = self {
                    DispatchQueue.main.async {
                        self_.output.storyCreatedWithError()
                    }
                }
            })
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
    
    func onMusicSelection(){
        guard let story_ = story else {
            return
        }
        output.goToAudioSelection(story: story_)
    }
    
}
