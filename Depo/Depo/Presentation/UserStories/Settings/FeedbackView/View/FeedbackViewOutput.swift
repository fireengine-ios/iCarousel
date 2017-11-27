//
//  FeedbackViewFeedbackViewOutput.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol FeedbackViewOutput {

    /**
        @author Oleg
        Notify presenter that view is ready
    */

    func viewIsReady()
    
    func onSend(selectedLanguage: LanguageModel)
    
}
