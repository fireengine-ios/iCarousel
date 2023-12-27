//
//  ConnectedDeviceViewController.swift
//  Lifebox
//
//  Created by Ozan Salman on 27.12.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

final class ConnectedDeviceViewController: BaseViewController {
    var output: ConnectedDeviceViewOutput!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.connectedDevices))
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
    }
}

extension ConnectedDeviceViewController: ConnectedDeviceViewInput {
    
}
