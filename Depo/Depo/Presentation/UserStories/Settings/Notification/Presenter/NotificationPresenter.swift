//
//  NotificationPresenter.swift
//  Depo
//
//  Created by yilmaz edis on 9.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class NotificationPresenter {
    weak var view: NotificationViewInput?
    var interactor: NotificationInteractorInput!
    var router: NotificationRouterInput!
}

// MARK: PackagesViewOutput
extension NotificationPresenter: NotificationViewOutput {
    func viewIsReady() {
        //view?.startActivityIndicator()
    }
    
    func viewWillAppear() {
        //view?.startActivityIndicator()
    }

}

// MARK: PackagesInteractorOutput
extension NotificationPresenter: NotificationInteractorOutput {


}

extension NotificationPresenter: NotificationPresenterInput {
    
}
