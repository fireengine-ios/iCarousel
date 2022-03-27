//
//  IntroduceIntroduceInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol IntroduceInteractorOutput: AnyObject {
    func signUpRequired(for user: GoogleUser)
    func passwordLoginRequired(for user: GoogleUser)
}
