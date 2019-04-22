//
//  UploadFilesSelectionUploadFilesSelectionRouter.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class UploadFilesSelectionRouter: BaseFilesGreedRouter {
    @objc override func showBack() {
        view.dismiss(animated: true, completion: {
            PremiumService.shared.showPopupForNewUserIfNeeded()
        })
    }
}
