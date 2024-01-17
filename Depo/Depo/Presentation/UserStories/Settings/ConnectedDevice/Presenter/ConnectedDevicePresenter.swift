//
//  ConnectedDevicePresenter.swift
//  Lifebox
//
//  Created by Ozan Salman on 27.12.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class ConnectedDevicePresenter {
    var view: ConnectedDeviceViewInput?
    var interactor: ConnectedDeviceInteractorInput!
    var router: ConnectedDeviceRouterInput!
    
}

extension ConnectedDevicePresenter: ConnectedDeviceInteractorOutput {
    func readQRCodeSuccess() {
        view?.readQRCodeSuccess()
    }
    
    func readQRCodeFail() {
        view?.readQRCodeFail()
    }
}

extension ConnectedDevicePresenter: ConnectedDeviceViewOutput {
    func callReadQRCode(referenceToken: String) {
        interactor.callReadQRCode(referenceToken: referenceToken)
    }
}
