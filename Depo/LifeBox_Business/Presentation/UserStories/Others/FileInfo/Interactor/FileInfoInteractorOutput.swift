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
    func displayShareInfo(_ sharingInfo: SharedFileInfo)
}
