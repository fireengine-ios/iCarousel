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
    }
    
    //MARK: Interactor Output

    func onKeepTapped() {
        router.back()
    }
    
    func onDeleteAllTapped() {
        let vc = PopUpController.with(title: TextConstants.settingsDeleteDuplicatedAlertTitle,
                             message: TextConstants.settingsDeleteDuplicatedAlertText,
                             image: .delete,
                             firstButtonTitle: TextConstants.cancel,
                             secondButtonTitle: TextConstants.ok,
                             secondAction: { [weak self] (vc) in
                                self?.moduleOutput?.deleteDuplicatedContacts()
                                self?.router.back()
                                vc.dismiss(animated: false, completion: nil)
                             })
        UIApplication.topController()?.present(vc, animated: false, completion: nil)
    }
    
}
