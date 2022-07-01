//
//  ManageContactsRouter.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ManageContactsRouter: ManageContactsRouterInput {
    
    func deleteContact(_ completion: @escaping VoidHandler) {
        self.showDeleteContactPopUp(okHandler: completion)
    }
    
    func showDeleteContactPopUp(okHandler: @escaping VoidHandler) {
        let controller = PopUpController.with(title: TextConstants.contactConfirmDeleteTitle,
                                              message: TextConstants.contactConfirmDeleteText,
                                              image: .delete,
                                              firstButtonTitle: TextConstants.errorAlertNopeBtnBackupAlreadyExist,
                                              secondButtonTitle: TextConstants.errorAlertYesBtnBackupAlreadyExist,
                                              secondAction: { vc in
                                                vc.close(completion: okHandler)
        })
        
        controller.open()

    }
}
