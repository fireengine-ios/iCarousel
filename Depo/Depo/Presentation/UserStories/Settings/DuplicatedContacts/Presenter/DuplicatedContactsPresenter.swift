//
//  DuplicatedContactsPresenter.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class DuplicatedContactsPresenter: DuplicatedContactsModuleInput, DuplicatedContactsViewOutput, DuplicatedContactsInteractorOutput {
    
    weak var view: DuplicatedContactsViewInput!
    weak var moduleOutput: DuplicatedContactsModuleOutput?
    var interactor: DuplicatedContactsInteractorInput!
    var router: DuplicatedContactsRouterInput!
    
    //MARK: View Output
    func viewIsReady() {
        
    }
    
    func onWillDisappear() {
        moduleOutput?.cancelDeletingDuplicatedContacts()
        moduleOutput?.backFromDuplicatedContacts()
    }
    
    //MARK: Interactor Output

    func onKeepTapped() {
        router.back()
    }
    
    func onDeleteAllTapped() {
        moduleOutput?.deleteDuplicatedContacts()
        router.back()
    }
}
