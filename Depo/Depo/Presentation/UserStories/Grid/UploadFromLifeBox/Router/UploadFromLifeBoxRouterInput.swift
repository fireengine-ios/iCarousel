//
//  UploadFromLifeBoxUploadFromLifeBoxRouterInput.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol UploadFromLifeBoxRouterInput {
    func goToFolder(destinationFolderUUID: String, outputFolderUUID: String, nController: UINavigationController)
}
