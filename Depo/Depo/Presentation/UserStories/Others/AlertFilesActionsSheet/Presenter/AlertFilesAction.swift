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
    let isTemplate: Bool

    init(title: String = "", icon: UIImage? = nil, isTemplate: Bool = true, handler: @escaping () -> Void = {}) {
        self.title = title
        self.icon = icon
        self.handler = handler
        self.isTemplate = isTemplate
    }
}
