//
//  RegistrationRegistrationInteractor.swift
//  Depo
//
//  Created by AlexanderP on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class RegistrationInteractor: RegistrationInteractorInput {

    weak var output: RegistrationInteractorOutput!
    let dataStorage = DataStorage()
    
    func requestTitle() {
        self.output.pass(title: "butter", forRowIndex: 0)
    }
    
    func prepareModels() {
        //PREPERes models here and call output
        self.output.prepearedModels(models: dataStorage.getModels())
    }
}
