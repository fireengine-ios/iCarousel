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
    
}

extension ConnectedDevicePresenter: ConnectedDeviceViewOutput {
    
}
