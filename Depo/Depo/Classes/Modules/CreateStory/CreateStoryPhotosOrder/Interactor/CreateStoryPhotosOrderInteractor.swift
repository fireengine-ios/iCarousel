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
        story_.storyPhotos.removeAll()
        story_.storyPhotos.append(contentsOf: array)
        
        //TODO: creation story on server
        
        let parameter = story_.photoStoryRequestParameter()
        if let parameter_ = parameter {
            CreateStoryService().createStory(createStory: parameter_, success: {[weak self] in
                let t = CreateStoryPreview(name: parameter_.title, imageuuid: parameter_.imageUUids, musicUUID: parameter_.audioUuid, musicId: parameter_.musicId)
                CreateStoryService().getPreview(preview: t, success: {
                    if let self_ = self {
                        DispatchQueue.main.async {
                            self_.output.storyCreated()
                        }
                    }
                }, fail: { (d) in
                    if let self_ = self {
                        DispatchQueue.main.async {
                            self_.output.storyCreatedWithError()
                        }
                    }
                })
                
                }, fail: {[weak self] (error) in
                    if let self_ = self {
                        DispatchQueue.main.async {
                            self_.output.storyCreatedWithError()
                        }
                    }
            })
        }
        
    }
    
}
