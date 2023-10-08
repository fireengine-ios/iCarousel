//
//  PhotoPrintInitilizer.swift
//  Depo
//
//  Created by Ozan Salman on 22.08.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

class PhotoPrintInitilizer: NSObject {
    
    class func initializeViewController(selectedPhotos: [SearchItemResponse]) -> PhotoPrintViewController {
        let viewController = PhotoPrintViewController(selectedPhotos: selectedPhotos)
        let configurator = PhotoPrintConfigurator()
        configurator.configure(viewController: viewController)
        return viewController
    }
}
