//
//  CustomTopBarSupportedSegmentedController.swift
//  Depo
//
//  Created by Alex Developer on 15.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

final class CustomTopBarSupportedSegmentedController: BaseViewController, NibInit {
    
    private(set) var viewControllers = [BaseViewController]()
    
    class func initWithControllers(with controllers: [BaseViewController]) -> CustomTopBarSupportedSegmentedController {
        let controller = CustomTopBarSupportedSegmentedController.initFromNib()
        controller.setup(with: controllers)
        return controller
    }
    
    func setup(with controllers: [BaseViewController]) {
        guard !controllers.isEmpty else {
            assertionFailure()
            return
        }
        viewControllers = controllers
    }
    
    
}
