//
//  AlertFilesAction.swift
//  Depo
//
//  Created by Hady on 6/14/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

struct AlertFilesAction {
    var title: String
    var icon: UIImage?
    let handler: () -> Void

    init(title: String = "", icon: UIImage? = nil, handler: @escaping () -> Void = {}) {
        self.title = title
        self.icon = icon
        self.handler = handler
    }
}
