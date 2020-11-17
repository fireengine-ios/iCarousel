//
//  FileInfoFileInfoRouterInput.swift
//  Depo
//
//  Created by Oleg on 18/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import Foundation

protocol FileInfoRouterInput {
    func openPrivateShare(for item: Item)
}

protocol FileInfoRouterOutput: class {
    func updateSharingInfo()
}
