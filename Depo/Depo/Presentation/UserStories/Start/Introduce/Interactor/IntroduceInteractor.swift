//
//  IntroduceIntroduceInteractor.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class IntroduceInteractor: IntroduceInteractorInput {

    weak var output: IntroduceInteractorOutput!
    let introduceDataStorage = IntroduceDataStorage()
    
    func PrepareModels() {
        output.models(models: self.introduceDataStorage.getModels())
    }
    
}
