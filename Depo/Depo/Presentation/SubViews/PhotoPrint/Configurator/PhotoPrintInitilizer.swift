//
//  PhotoPrintInitilizer.swift
//  Depo
//
//  Created by Ozan Salman on 22.08.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class PhotoPrintInitilizer: NSObject {
    
    class func initializeViewController() -> PhotoPrintViewController {
        let viewController = PhotoPrintViewController()
        let configurator = PhotoPrintConfigurator()
        configurator.configure(viewController: viewController)
        return viewController
    }
}
