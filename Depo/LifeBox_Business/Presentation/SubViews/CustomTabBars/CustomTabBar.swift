//
//  CustomEdinitgTabBar.swift
//  Depo
//
//  Created by Aleksandr on 6/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

typealias ImageNameToTitleTupple = (imageName: String, title: String, accessibilityTitle: String)

class CustomTabBar: UITabBar {
    
    func setupItems() {
        tintColor = ColorConstants.blueColor
        
        let items: [CustomTabBarItem] = TabBarItem.allCases.map { item -> CustomTabBarItem in
            let tabBarItem = CustomTabBarItem(title: item.title, image: item.icon, tag: 0)
            tabBarItem.isAccessibilityElement = true
            
            if !item.accessibilityLabel.isEmpty {
                tabBarItem.accessibilityLabel = item.accessibilityLabel
            }
            
            ///at iOS13 tabBatItems without insets looks like tabBatItems with insets at other iOS versions
            if !Device.isIpad && Device.operationSystemVersionLessThen(13) {
                tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            }
            
            return tabBarItem
        }
        
        items[2].isEnabled = false
        
        setItems(items, animated: false)
    }
    
}
