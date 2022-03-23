//
//  IntroduceIntroduceViewOutput.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol IntroduceViewOutput {

    func viewIsReady()
    func onStartUsingLifeBox()
    func onLoginButton()
    func pageChanged(page: Int)
    func onContinueWithGoogle(with user: GoogleUser)
}
