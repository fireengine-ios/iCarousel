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
    
    func openPrivateShareContacts(with shareInfo: SharedFileInfo) {
        let controller = router.privateShareContacts(with: shareInfo) { [weak self] in
            self?.output?.deleteSharingInfo()
        }
        router.pushViewController(viewController: controller)
    }
    
    func openPrivateShareAccessList(projectId: String, uuid: String, contact: SharedContact, fileType: FileType) {
        let controller = router.privateShareAccessList(projectId: projectId,
                                                       uuid: uuid,
                                                       contact: contact,
                                                       fileType: fileType)
        router.pushViewController(viewController: controller)
    }
}
