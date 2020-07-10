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
    
    private func prepareToDismiss() {
        view?.prepareToDismiss()
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
        
        SnackbarManager.shared.show(type: .critical, message: TextConstants.createStoryPopUpMessage, action: .ok) { [weak self] in
            self?.prepareToDismiss()
            self?.router.goToMain()
        }
    }
    
    func storyCreatedWithError() {
        asyncOperationSuccess()
        
        let titleDesign: DesignText = .full(attributes: [
            .foregroundColor : ColorConstants.lightText,
            .font : UIFont.TurkcellSaturaRegFont(size: 16)
        ])
        
        let messageDesign: DesignText = .full(attributes: [
            .foregroundColor : ColorConstants.darkBlueColor,
            .font : UIFont.TurkcellSaturaDemFont(size: 20)
        ])
        
        router.presentFinishPopUp(image: .error,
                                  title: TextConstants.errorAlert,
                                  storyName: "",
                                  titleDesign: titleDesign,
                                  message: TextConstants.createStoryNotCreated,
                                  messageDesign: messageDesign,
                                  buttonTitle: TextConstants.ok) { [weak self] in
                                    self?.prepareToDismiss()
                                    self?.router.goToMain()
        }
    }
    
}

// MARK: CreateStoryPreviewInteractorOutput
extension CreateStoryPreviewPresenter: CreateStoryPreviewInteractorOutput {
    func startShowVideoFromResponse(response: CreateStoryResponse) {
        view?.startShowVideoFromResponse(response: response)
    }
}

// MARK: CreateStoryPreviewModuleInput
extension CreateStoryPreviewPresenter: CreateStoryPreviewModuleInput {

}
