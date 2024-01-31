//
//  ConnectedDeviceInteractor.swift
//  Lifebox
//
//  Created by Ozan Salman on 27.12.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class ConnectedDeviceInteractor {
    
    var output: ConnectedDeviceInteractorOutput!
    private let service = QRCodeService()
    
    func readQRCode(referenceToken: String) {
        service.readQRCode(referenceToken: referenceToken) { [weak self] result in
            switch result {
            case .success(let response):
                self?.output.readQRCodeSuccess()
            case .failed(let error):
                self?.output.readQRCodeFail()
            }
        }
    }
}

extension ConnectedDeviceInteractor: ConnectedDeviceInteractorInput {
    func callReadQRCode(referenceToken: String) {
        readQRCode(referenceToken: referenceToken)
    }
}
