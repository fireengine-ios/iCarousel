//
//  CreateStoryNameCreateStoryNamePresenter.swift
//  Depo
//
//  Created by Oleg on 01/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryNamePresenter: CreateStoryNameModuleInput, CreateStoryNameViewOutput, CreateStoryNameInteractorOutput {

    weak var view: CreateStoryNameViewInput!
    var interactor: CreateStoryNameInteractorInput!
    var router: CreateStoryNameRouterInput!
    
    private var _items: [BaseDataSourceItem]?
    
    var items: [BaseDataSourceItem]? {
        get { return _items }
        set { _items = newValue }
    }
    
    func viewIsReady() {
        
    }
    
    func showEmptyNamePopup() {
        UIApplication.showErrorAlert(message: TextConstants.createStoryEmptyTextError)
    }
    
    func onCreateStory(storyName: String?) {
        guard let text = storyName else {
            showEmptyNamePopup()
            return
        }
        
        let checkNameString = text.replacingOccurrences(of: " ", with: "")
        if checkNameString.isEmpty {
            showEmptyNamePopup()
            return
        }
        
        if (text.isEmpty) {
            showEmptyNamePopup()
        } else {
            interactor.trackStoryNameGiven()
            if let items = items {
                interactor.onCreateStory(storyName: text, items: items)
            } else {
                interactor.onCreateStory(storyName: text)
            }
        }
    }
    
    func goToSelectionPhoto(forStory story: PhotoStory) {
        router.goToSelectionPhotosForStory(story: story)
    }
    
    func goToFavoriteSelectionPhoto(forStory story: PhotoStory) {
        router.goToFavoriteSelectionPhotosForStory(story: story)
    }
    
    func goToPhotosOrderForStory(story: PhotoStory) {
        router.goToPhotosOrderForStory(story: story)
    }
}
