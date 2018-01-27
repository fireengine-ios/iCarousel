//
//  CreateStoryNameCreateStoryNameInteractor.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryNameInteractor: CreateStoryNameInteractorInput {

    weak var output: CreateStoryNameInteractorOutput!
    var needSelectionItems: Bool = false
    
    func onCreateStory(storyName: String){
        let story = PhotoStory(name: storyName)
        output.goToSelectionPhoto(forStory: story)
    }
    
    func onCreateStory(storyName: String, items: [BaseDataSourceItem]) {
        let story = PhotoStory(name: storyName)
        
        var storyItems = [Item]()
        
        for item in items {
            if let storyItem = item as? Item {
                storyItems.append(storyItem)
            }
        }
        
        story.storyPhotos = storyItems
        if storyItems.isEmpty || needSelectionItems {
            output.goToSelectionPhoto(forStory: story)
        } else {
            output.goToPhotosOrderForStory(story: story)
        }
    }
}
