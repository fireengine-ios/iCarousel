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
        let attributes: [NSAttributedString.Key : Any] = [.font: font]
        setTitleTextAttributes(attributes, for: .normal)
        
    }
    
    func set(textColor: UIColor) {
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: textColor]
        setTitleTextAttributes(attributes, for: .normal)
    }
}
