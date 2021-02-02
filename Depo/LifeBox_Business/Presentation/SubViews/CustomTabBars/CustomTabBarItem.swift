//
//  CustomTabBarItem.swift
//  Depo
//
//  Created by Aleksandr on 6/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CustomTabBarItem: UITabBarItem {
    
    override init() {
        super.init()
        setupTitle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTitle()
    }

    func setupTitle() {
        let font: UIFont
        font = UIFont.TurkcellSaturaMedFont(size: 10)
        
        setTitleTextAttributes([.font: font], for: .normal)
    }

}
