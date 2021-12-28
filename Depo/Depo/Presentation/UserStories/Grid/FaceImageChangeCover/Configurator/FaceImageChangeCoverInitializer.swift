//
//  FaceImageChangeCoverInitializer.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol FaceImageChangeCoverModuleOutput: AnyObject {
    func onAlbumCoverSelected(item: WrapData)
}

final class FaceImageChangeCoverInitializer: NSObject {

    class func initializeController(with nibName: String, albumUUID: String, personItem: Item?, coverType: CoverType?, moduleOutput: FaceImageChangeCoverModuleOutput?) -> UIViewController {
        let viewController = FaceImageChangeCoverViewController(nibName: nibName, bundle: nil)
    
        let configurator = FaceImageChangeCoverConfigurator()
        let itemsService = FaceImageDetailService(albumUUID: albumUUID, requestSize: 100)
        configurator.configure(viewController: viewController, itemsService: itemsService, personItem: personItem, coverType: coverType, moduleOutput: moduleOutput)
        
        return viewController
    }
}
