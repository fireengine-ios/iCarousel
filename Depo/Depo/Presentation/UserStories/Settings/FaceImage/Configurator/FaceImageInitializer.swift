//
//  FaceImageInitializer.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImageInitializer: NSObject {
    
//    var faceImageViewController: FaceImageViewController!
    
    class func initializeViewController(with nibName: String) -> UIViewController {
        let viewController = FaceImageViewController(nibName: nibName, bundle: nil)
        let configurator = FaceImageConfigurator()
        configurator.configureModuleForViewInput(viewInput: viewController)
        return viewController
    }
}
