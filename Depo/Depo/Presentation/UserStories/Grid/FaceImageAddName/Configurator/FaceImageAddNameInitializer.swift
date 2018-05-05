//
//  FaceImageAddNameInitializer.swift
//  Depo
//
//  Created by Harhun Brothers on 07.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class FaceImageAddNameInitializer: NSObject {
    class func initializeViewController(with nibName: String, item: WrapData, moduleOutput: FaceImagePhotosModuleOutput?, isSearchItem: Bool) -> UIViewController {
        let viewController = FaceImageAddNameViewController(nibName: nibName, bundle: nil)
        
        let configurator = FaceImageAddNameConfigurator()
        
        configurator.configure(viewController: viewController, item: item, moduleOutput: moduleOutput, isSearchItem: isSearchItem)
        
        return viewController
    }
}
