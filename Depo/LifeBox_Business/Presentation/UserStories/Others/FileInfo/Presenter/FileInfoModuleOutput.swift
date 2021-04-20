//
//  FileInfoModuleOutput.swift
//  Depo
//
//  Created by MacBook on 18.01.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol FileInfoModuleOutput: class {
    func didRenameItem(_ item: BaseDataSourceItem)
}
