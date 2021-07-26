//
//  FeedbackViewFeedbackViewInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 01/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol FeedbackViewInteractorOutput: BaseAsyncOperationInteractorOutput {
    func fail(text: String)
    func languageRequestSended(email: String, text: String)    
}
