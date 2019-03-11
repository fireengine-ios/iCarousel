//
//  CreateStoryPreviewCreateStoryPreviewPresenter.swift
//  Depo
//
//  Created by Oleg on 18/10/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class CreateStoryPreviewPresenter: BasePresenter {
    weak var view: CreateStoryPreviewViewInput?
    var interactor: CreateStoryPreviewInteractorInput!
    var router: CreateStoryPreviewRouterInput!
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}

// MARK: CreateStoryPreviewViewOutput
extension CreateStoryPreviewPresenter: CreateStoryPreviewViewOutput {
    
    func viewIsReady() {
        interactor.viewIsReady()
    }
    
    func onSaveStory() {
        startAsyncOperation()
        interactor.onSaveStory()
    }
    
    func storyCreated() {
        asyncOperationSuccess()
        MenloworksAppEvents.onStoryCreated()
        
        let controller = PopUpController.with(title: TextConstants.pullToRefreshSuccess,
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
    
    func storyCreatedWithError() {
        asyncOperationSuccess()
        
        let controller = PopUpController.with(title: TextConstants.errorAlert,
                                              message: TextConstants.createStoryNotCreated,
                                              image: .error,
                                              buttonTitle: TextConstants.ok,
                                              action: { [weak self] vc in
                                                vc.close { [weak self] in
                                                    self?.router.goToMain()
                                                }
        })
        UIApplication.topController()?.present(controller, animated: false, completion: nil)
    }
}

// MARK: CreateStoryPreviewInteractorOutput
extension CreateStoryPreviewPresenter: CreateStoryPreviewInteractorOutput {
    func startShowVideoFromResponce(responce: CreateStoryResponce) {
        view?.startShowVideoFromResponce(responce: responce)
    }
}

// MARK: CreateStoryPreviewModuleInput
extension CreateStoryPreviewPresenter: CreateStoryPreviewModuleInput {

}
