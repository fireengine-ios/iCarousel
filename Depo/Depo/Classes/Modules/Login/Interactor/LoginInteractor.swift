//
//  LoginLoginInteractor.swift
//  Depo
//
//  Created by Oleg on 08/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class LoginInteractor: LoginInteractorInput {

    weak var output: LoginInteractorOutput!
    var dataStorage = LoginDataStorage()
    
    func prepareModels(){
        self.output.models(models: self.dataStorage.getModels())
    }
    
}
