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
        let controller = router.privateShare(items: [item])
        router.presentViewController(controller: controller)
    }
    
    func openPrivateShareContacts(with shareInfo: SharedFileInfo) {
        let controller = router.privateShareContacts(with: shareInfo)
        router.pushViewController(viewController: controller)
    }
    
    func openPrivateShareAccessList(projectId: String, uuid: String, contact: SharedContact, fileType: FileType) {
        let controller = router.privateShareAccessList(projectId: projectId,
                                                       uuid: uuid,
                                                       contact: contact,
                                                       fileType: fileType)
        let navC = UINavigationController(rootViewController: controller)
        router.presentViewController(controller: navC)
    }
}
