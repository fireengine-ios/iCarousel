//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderPresenter.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPhotosOrderPresenter: BasePresenter, CreateStoryPhotosOrderModuleInput, CreateStoryPhotosOrderViewOutput, CreateStoryPhotosOrderInteractorOutput, CustomPopUpAlertActions {

    weak var view: CreateStoryPhotosOrderViewInput!
    var interactor: CreateStoryPhotosOrderInteractorInput!
    var router: CreateStoryPhotosOrderRouterInput!
    
    let custoPopUp = CustomPopUp()

    func viewIsReady() {
        interactor.viewIsReady()
    }
    
    func showStory(story: PhotoStory){
        view.showStory(story: story)
    }
    
    func onNextButton(array: [Item]){
        startAsyncOperation()
        interactor.onNextButton(array: array)
    }
    
    func storyCreated(){
        asyncOperationSucces()
        custoPopUp.delegate = self
        custoPopUp.showCustomInfoAlert(withTitle: TextConstants.pullToRefreshSuccess,
                                       withText: TextConstants.createStoryCreated,
                                       okButtonText: TextConstants.createStoryPhotosMaxCountAllertOK)
    }
    
    func storyCreatedWithError(){
        asyncOperationSucces()
        custoPopUp.delegate = self
        custoPopUp.showCustomAlert(withText: TextConstants.createStoryNotCreated,
                                   okButtonText: TextConstants.createStoryPhotosMaxCountAllertOK)
    }
    
    func onMusicSelection(){
        interactor.onMusicSelection()
    }
    
    func goToAudioSelection(story: PhotoStory){
        router.goToMusicSelection(story: story, navigationController: view.getNavigationControllet())
    }
    
    func audioNotSelectedError(){
        asyncOperationSucces()
        custoPopUp.showCustomAlert(withText: TextConstants.createStoryNoSelectedAudioError, okButtonText: TextConstants.createFolderEmptyFolderButtonText)
    }
    
    func goToStoryPreview(story: PhotoStory, responce: CreateStoryResponce){
        asyncOperationSucces()
        router.goToStoryPreviewViewController(forStory: story, responce: responce, navigationController: view.getNavigationControllet())
    }
    
    //MARK : Custom Pop Up
    
    func cancelationAction(){
        router.goToMain()
    }
    
    func otherAction(){
        
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}
