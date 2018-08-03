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
    var isFavorites: Bool = false
    
    private let analyticsManager: AnalyticsService = factory.resolve()
    
    func onCreateStory(storyName: String) {
        let story = PhotoStory(name: storyName)
        if (isFavorites) {
            output.goToFavoriteSelectionPhoto(forStory: story)
        } else {
            output.goToSelectionPhoto(forStory: story)
        }
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
            if isFavorites {
                output.goToFavoriteSelectionPhoto(forStory: story)
            } else {
                output.goToSelectionPhoto(forStory: story)
            }
        } else {
            output.goToPhotosOrderForStory(story: story)
        }
    }
    
    func trackScreen() {
        analyticsManager.logScreen(screen: .createStoryName)
    }
    
    func trackStoryNameGiven() {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .story, eventLabel: .crateStory(.name))
    }
}
