//
//  FeedbackViewFeedbackViewInteractorInput.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol FeedbackViewInteractorInput {

    func onSend(selectedLanguage: LanguageModel)
    func trackScreen()
}
