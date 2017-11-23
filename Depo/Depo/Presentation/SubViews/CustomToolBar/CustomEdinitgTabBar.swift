//
//  CustomEdinitgTabBar.swift
//  Depo
//
//  Created by Aleksandr on 6/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

typealias imageNameToTitleTupple = (String, String)

class CustomEdinitgTabBar: UITabBar {
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init?(coder: aDecoder)
//    }
    
    func adjustConstraintsTabbar(toView view: UIView) {
        //setup constraints on bot, leading, trailing
        let midTrailinLeading = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[item1]-(0)-|",
                                                               options: [], metrics: nil,
                                                               views: ["item1" : self])
        let bot = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        
        view.addConstraints(midTrailinLeading + [bot])
    }
    
    func setupItems(withImageToTitleNames names: [imageNameToTitleTupple], withTintColor newTintColor: UIColor = ColorConstants.blueColor, withbarTintColor tabBarTintColor: UIColor?, animated: Bool = false) {
        tintColor = newTintColor
        if tabBarTintColor != nil {
            barTintColor = tabBarTintColor
        }
        var i = 0
        var tempoItems: [CustomTabBarItem] = []
        for name in names {
            i += 1
            let item = CustomTabBarItem(title: name.0, image: UIImage(named: name.1), tag: i)

            tempoItems.append(item)
        }
        
        setItems(tempoItems, animated: animated)
    }
    
    func changeColor(normalColor: UIColor, selectedColoer: UIColor) {
        
    }
    
}
