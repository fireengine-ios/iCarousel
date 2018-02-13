//
//  ManageContactsRouter.swift
//  Depo
//
//  Created by Raman on 10/01/2018.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class ManageContactsRouter: ManageContactsRouterInput {
    
    func deleteContact(_ completion: @escaping (() -> Void)) {
        self.showDeleteContactPopUp(okHandler: completion)
    }
    
    func showDeleteContactPopUp(okHandler: @escaping () -> Void) {
        let controller = PopUpController.with(title: TextConstants.contactConfirmDeleteTitle,
                                              message: TextConstants.contactConfirmDeleteText,
                                              image: .delete,
                                              firstButtonTitle: TextConstants.errorAlertNopeBtnBackupAlreadyExist,
                                              secondButtonTitle: TextConstants.errorAlertYesBtnBackupAlreadyExist,
                                              secondAction: { vc in
                                                vc.close(completion: okHandler)
        })
        
        RouterVC().presentViewController(controller: controller)
    }
}
