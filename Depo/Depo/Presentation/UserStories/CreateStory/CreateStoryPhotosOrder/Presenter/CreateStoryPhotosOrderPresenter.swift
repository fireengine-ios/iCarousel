//
//  CreateStoryPhotosOrderCreateStoryPhotosOrderPresenter.swift
//  Depo
//
//  Created by Oleg on 03/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPhotosOrderPresenter: BasePresenter, CreateStoryPhotosOrderModuleInput, CreateStoryPhotosOrderViewOutput, CreateStoryPhotosOrderInteractorOutput {

    weak var view: CreateStoryPhotosOrderViewInput!
    var interactor: CreateStoryPhotosOrderInteractorInput!
    var router: CreateStoryPhotosOrderRouterInput!
    
    func viewIsReady() {
        interactor.viewIsReady()
    }
    
    func showStory(story: PhotoStory) {
        view.showStory(story: story)
    }
    
    func onNextButton(array: [Item]) {
        startAsyncOperation()
        interactor.onNextButton(array: array)
    }
    
    func storyCreated() {
        asyncOperationSucces()
        
        let controller = PopUpController.with(title: TextConstants.success,
                                              message: TextConstants.createStoryCreated,
                                              image: .success,
                                              buttonTitle: TextConstants.ok,
                                              action: { [weak self] vc in
                                                vc.close { [weak self] in
                                                    self?.router.goToMain()
                                                }
        })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
    
    func createdStoryFailed(with error: ErrorResponse) {
        asyncOperationSucces()
        
        let errorMessage = error.isNetworkError ? error.description : TextConstants.createStoryNotCreated
        view.showErrorAlert(message: errorMessage)
    }
    
    func onMusicSelection() {
        interactor.onMusicSelection()
    }
    
    func goToAudioSelection(story: PhotoStory) {
        router.goToMusicSelection(story: story, navigationController: view.getNavigationControllet())
    }
    
    func audioNotSelectedError() {
        asyncOperationSucces()
        router.showMusicEmptyPopUp { [weak self] in
            self?.interactor.onMusicSelection()
        }
    }
    
    func goToStoryPreview(story: PhotoStory, responce: CreateStoryResponce) {
        asyncOperationSucces()
        router.goToStoryPreviewViewController(forStory: story, responce: responce, navigationController: view.getNavigationControllet())
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
    
}
