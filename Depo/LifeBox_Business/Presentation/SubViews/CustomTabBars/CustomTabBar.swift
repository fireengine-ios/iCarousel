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
        tintColor = ColorConstants.bottomBarTint.color
        
        let items: [CustomTabBarItem] = TabBarItem.allCases.map { item -> CustomTabBarItem in
            let tabBarItem = CustomTabBarItem(title: item.title, image: item.icon, selectedImage: item.iconSelected)
            tabBarItem.isAccessibilityElement = true
            
            if !item.accessibilityLabel.isEmpty {
                tabBarItem.accessibilityLabel = item.accessibilityLabel
            }
            
            ///at iOS13 tabBatItems without insets looks like tabBatItems with insets at other iOS versions
            if !Device.isIpad && Device.operationSystemVersionLessThen(13) {
                tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            }
            
            tabBarItem.imageInsets = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
            
            tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -8)
            return tabBarItem
        }
        
        setItems(items, animated: false)
    }
    
}
