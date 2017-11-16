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
    
    let custoPopUp = CustomPopUp()

    func viewIsReady() {
        
    }
    
    func showEmptyNamePopup(){
        custoPopUp.showCustomAlert(
            withText: TextConstants.createStoryEmptyTextError,
            okButtonText: TextConstants.createFolderEmptyFolderButtonText)
    }
    
    func onCreateStory(storyName: String?){
        guard let text = storyName else {
            showEmptyNamePopup()
            return
        }
        if (text.isEmpty){
            showEmptyNamePopup()
        }else{
            interactor.onCreateStory(storyName: text)
        }
    }
    
    func goToSelectionPhoto(forStory story: PhotoStory){
        router.goToSelectionPhotosForStory(story: story)
    }
}
