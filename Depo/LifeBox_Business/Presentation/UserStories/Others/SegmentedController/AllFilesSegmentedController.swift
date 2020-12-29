//
//  AllFilesSegmentedController.swift
//  Depo
//
//  Created by Andrei Novikau on 17.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

final class AllFilesSegmentedController: SegmentedController {
    
    override static func initWithControllers(_ controllers: [UIViewController], alignment: Alignment) -> AllFilesSegmentedController {
        let controller = AllFilesSegmentedController.initFromNib()
        controller.setup(with: controllers, alignment: alignment)
        return controller
    }
    
    override func canSwitchSegment(from oldIndex: Int, to newIndex: Int) -> Bool {
        if viewControllers[newIndex] is PrivateShareSharedFilesViewController {
            openSharedFiles()
            return false
        }
        return true
    }
    
    private func openSharedFiles() {
        let router = RouterVC()
        router.pushViewController(viewController: router.sharedFiles)
    }
}
