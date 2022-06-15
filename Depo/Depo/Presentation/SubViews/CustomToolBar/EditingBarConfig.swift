//
//  EditingBarConfig.swift
//  Depo
//
//  Created by Aleksandr on 8/3/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

struct EditingBarConfig {
    let elementsConfig: [ElementTypes]
    let style: UIBarStyle
    let tintColor: UIColor?
    let unselectedItemTintColor: UIColor?
    let barTintColor: UIColor?

    init(
        elementsConfig: [ElementTypes],
        style: UIBarStyle,
        tintColor: UIColor? = nil,
        unselectedItemTintColor: UIColor? = nil,
        barTintColor: UIColor? = nil
    ) {
        self.elementsConfig = elementsConfig
        self.style = style
        self.tintColor = tintColor
        self.unselectedItemTintColor = unselectedItemTintColor
        self.barTintColor = barTintColor
    }
}
