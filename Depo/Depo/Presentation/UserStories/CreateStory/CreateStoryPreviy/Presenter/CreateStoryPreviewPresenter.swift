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

        let words = TextConstants.createStoryPopUpMessage.components(separatedBy: ".")
        let title = words[0]
        var message = ""
        if words.count > 1 {
            message = words[1]
        }
        
        let controller = PopUpController.with(
            title: title,
            message: message,
            image: .clock,
            buttonTitle: TextConstants.ok,
            action: { [weak self] vc in
                vc.close {
                    self?.prepareToDismiss()
                    self?.router.goToMain()
                }
            })

        controller.open()
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
