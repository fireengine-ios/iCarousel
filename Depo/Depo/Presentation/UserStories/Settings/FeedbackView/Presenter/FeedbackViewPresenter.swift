//
//  FeedbackViewFeedbackViewPresenter.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FeedbackViewPresenter: BasePresenter, FeedbackViewModuleInput, FeedbackViewOutput, FeedbackViewInteractorOutput {

    weak var view: FeedbackViewInput!
    var interactor: FeedbackViewInteractorInput!
    var router: FeedbackViewRouterInput!

    func viewIsReady() {
        view.languagesUploaded(languages: LanguageModel.availableLanguages())
        interactor.trackScreen()
    }
    
    func onSend(selectedLanguage: LanguageModel) {
        interactor.onSend(selectedLanguage: selectedLanguage)
    }
        
    //interactor output
    
    func fail(text: String) {
        asyncOperationSuccess()
        view.fail(text: text)
    }
    
    func languageRequestSended(email: String, text: String) {
        view.languageRequestSended(email: email, text: text)
    }
    
    //MARK : BasePresenter
    
    override func outputView() -> Waiting? {
        return view as? Waiting
    }
}
