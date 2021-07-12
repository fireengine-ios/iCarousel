//
//  IntroduceIntroduceViewInput.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

protocol IntroduceViewInput: AnyObject {

    /**
        @author Oleg
        Setup initial state of the view
    */

    func setupInitialState(models: [IntroduceModel])
}
