//
//  MapSearchInteractorOutput.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol MapSearchInteractorOutput: AnyObject {
    func receivedMediaGroups(_ groups: [MapMediaGroup])
}
