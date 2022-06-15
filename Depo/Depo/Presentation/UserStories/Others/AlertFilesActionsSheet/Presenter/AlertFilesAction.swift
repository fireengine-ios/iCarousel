//
//  AlertFilesAction.swift
//  Depo
//
//  Created by Hady on 6/14/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

struct AlertFilesAction {
    let title: String
    let icon: AppImage?
    let handler: () -> Void

    init(title: String = "", icon: AppImage? = nil, handler: @escaping () -> Void = {}) {
        self.title = title
        self.icon = icon
        self.handler = handler
    }
}
