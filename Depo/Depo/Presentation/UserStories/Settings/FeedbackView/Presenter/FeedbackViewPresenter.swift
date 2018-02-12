//
//  FeedbackViewFeedbackViewPresenter.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FeedbackViewPresenter:BasePresenter, FeedbackViewModuleInput, FeedbackViewOutput, FeedbackViewInteractorOutput {

    weak var view: FeedbackViewInput!
    var interactor: FeedbackViewInteractorInput!
    var router: FeedbackViewRouterInput!

    func viewIsReady() {
        interactor.viewIsReady()
    }
    
    func onSend(selectedLanguage: LanguageModel){
        interactor.onSend(selectedLanguage: selectedLanguage)
    }
    
    func onTextDidChange(text: String) {
        view.setSendButton(isEnabled: !text.isEmpty)
    }
    
    //interactor output
    
    func languagesUploaded(lanuages:[LanguageModel]){
        asyncOperationSucces()
        view.languagesUploaded(lanuages: lanuages)
    }
    
    func fail(text: String){
        asyncOperationSucces()
        view.fail(text: text)
    }
    
    func languageRequestSended(text: String){
        view.languageRequestSended(text: text)
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}
