//
//  PhotoVideoDetailPhotoVideoDetailRouterInput.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol PhotoVideoDetailRouterInput {
    
    func onInfo(object: Item)
    
    func goBack(navigationConroller: UINavigationController?)
    
    func showConfirmationPopup(completion: @escaping () -> ())
 
    func openPrivateShare(for item: Item)
    
    func openPrivateShareContacts(with shareInfo: SharedFileInfo)
    
    func openPrivateShareAccessList(projectId: String, uuid: String, contact: SharedContact, fileType: FileType)
}

protocol PhotoVideoDetailRouterOutput: class {
    func updateShareInfo()
}
