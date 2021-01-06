//
//  FeedbackViewFeedbackViewInput.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol FeedbackViewInput: class {
    func languagesUploaded(languages: [LanguageModel])
    func fail(text: String)
    func languageRequestSended(email: String, text: String)
    func setSendButton(isEnabled: Bool)
}
