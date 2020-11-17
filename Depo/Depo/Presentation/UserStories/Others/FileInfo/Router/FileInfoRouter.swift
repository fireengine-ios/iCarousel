//
//  FileInfoFileInfoRouter.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

class FileInfoRouter: FileInfoRouterInput {
    
    weak var output: FileInfoRouterOutput?
    private lazy var router = RouterVC()
    
    func openPrivateShare(for item: Item) {
        let controller = router.privateShare(items: [item]) { [weak self] success in
            if success {
                self?.output?.updateSharingInfo()
            }
        }
        router.presentViewController(controller: controller)
    }
}
