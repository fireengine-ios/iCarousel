//
//  EditingBarConfig.swift
//  Depo
//
//  Created by Aleksandr on 8/3/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct EditingBarConfig {
    let elementsConfig: [ElementTypes]
    let style: BottomActionsBarStyle
}

extension EditingBarConfig {
    static let emptyConfig = EditingBarConfig(elementsConfig: [], style: .opaque)
}
