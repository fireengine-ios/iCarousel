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
        MenloworksAppEvents.onStoryCreated()
        
        let storyName = interactor.story?.storyName ?? ""
        let title = String(format: TextConstants.createStoryPopUpTitle, storyName)
        let titleFullAttributes: [NSAttributedStringKey : Any] = [
            .font : UIFont.TurkcellSaturaFont(size: 18),
            .foregroundColor : UIColor.black,
            .kern : 0
        ]
        
        let storyNameAttributes: [NSAttributedStringKey : Any] = [.font: UIFont.TurkcellSaturaBolFont(size: 18)]
        
        let path = TextConstants.createStoryPathToStory
        let message = String(format: TextConstants.createStoryPopUpMessage, path)
        
        let messageParagraphStyle = NSMutableParagraphStyle()
        messageParagraphStyle.paragraphSpacing = 8
        messageParagraphStyle.alignment = .center
        let messageFullAttributes: [NSAttributedStringKey : Any] = [
            .font : UIFont.TurkcellSaturaMedFont(size: 16),
            .foregroundColor : ColorConstants.blueGrey,
            .paragraphStyle : messageParagraphStyle,
            .kern : 0
        ]
        
        let messagePathAttributes: [NSAttributedStringKey : Any] = [.font: UIFont.TurkcellSaturaBolFont(size: 16)]
        
        router.presentFinishPopUp(image: .custom(UIImage(named: "Path")),
                                  title: title,
                                  storyName: storyName,
                                  titleDesign: .partly(parts: [title : titleFullAttributes, storyName : storyNameAttributes]),
                                  message: message,
                                  messageDesign: .partly(parts: [message : messageFullAttributes, path : messagePathAttributes]),
                                  buttonTitle: TextConstants.ok) { [weak self] in
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
