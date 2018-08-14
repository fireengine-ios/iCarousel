//
//  CreateStorySelectionInteractor.swift
//  Depo
//
//  Created by Oleg on 02/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStorySelectionInteractor: BaseFilesGreedInteractor {

    var photoStory: PhotoStory?
    
    override func viewIsReady() {
        guard let story = photoStory else {
            return
        }
        if let out = output as? CreateStorySelectionInteractorOutput {
            out.configurateWithPhotoStory(story: story)
        }
    }
    
    override func trackScreen() {
        if remoteItems is CreateStoryMusicService {
            analyticsManager.logScreen(screen: .createStoryMusicSelection)
            analyticsManager.trackDimentionsEveryClickGA(screen: .createStoryMusicSelection)
        } else {
            analyticsManager.logScreen(screen: .createStoryPhotosSelection)
            analyticsManager.trackDimentionsEveryClickGA(screen: .createStoryPhotosSelection)
        }
    }
    
    func onChangeSorce(isYourUpload: Bool) {
        if isYourUpload {
            remoteItems = MusicService(requestSize: 100)
        } else {
            remoteItems = CreateStoryMusicService()
        }
        
    }

    override func trackItemsSelected() {
       
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .story, eventLabel: .crateStory(.musicSelect))
        
    }
    
}
