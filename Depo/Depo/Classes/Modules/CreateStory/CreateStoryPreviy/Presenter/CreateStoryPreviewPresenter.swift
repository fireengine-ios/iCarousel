//
//  CreateStoryPreviewCreateStoryPreviewPresenter.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPreviewPresenter: BasePresenter, CustomPopUpAlertActions {
    weak var view: CreateStoryPreviewViewInput?
    var interactor: CreateStoryPreviewInteractorInput!
    var router: CreateStoryPreviewRouterInput!
    
    let custoPopUp = CustomPopUp()
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
    func cancelationAction(){
        router.goToMain()
    }
    
    func otherAction(){
        
    }
    
}

// MARK: CreateStoryPreviewViewOutput
extension CreateStoryPreviewPresenter: CreateStoryPreviewViewOutput {
    
    func viewIsReady() {
        interactor.viewIsReady()
    }
    
    func onSaveStory(){
        startAsyncOperation()
        interactor.onSaveStory()
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
    
}

// MARK: CreateStoryPreviewInteractorOutput
extension CreateStoryPreviewPresenter: CreateStoryPreviewInteractorOutput {
    func startShowVideoFromResponce(responce: CreateStoryResponce){
        view?.startShowVideoFromResponce(responce: responce)
    }
}

// MARK: CreateStoryPreviewModuleInput
extension CreateStoryPreviewPresenter: CreateStoryPreviewModuleInput {

}
