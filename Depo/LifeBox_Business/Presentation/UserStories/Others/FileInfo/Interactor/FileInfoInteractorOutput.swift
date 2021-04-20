//
//  FileInfoFileInfoInteractorOutput.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol FileInfoInteractorOutput: class {
    func setObject(object: BaseDataSourceItem)
    func displayEntityInfo(_ sharingInfo: SharedFileInfo)
    func showProgress()
    func hideProgress()
}
