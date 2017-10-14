//
//  CustomTabBarItem.swift
//  Depo
//
//  Created by Aleksandr on 6/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CustomTabBarItem: UITabBarItem {
    
    func setupTitle() {
        let font = UIFont.TurkcellSaturaBolFont(size: 14)
        setTitleTextAttributes([NSAttributedStringKey.font: font], for: .normal)
    }
    
    override func awakeFromNib() {
        setupTitle()
    }
}
