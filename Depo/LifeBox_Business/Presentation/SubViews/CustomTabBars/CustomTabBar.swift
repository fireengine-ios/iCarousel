//
//  CustomEdinitgTabBar.swift
//  Depo
//
//  Created by Aleksandr on 6/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum TabBarItem: CaseIterable {
    case plus
    case allFiles
    
    var title: String {
        switch self {
        case .plus:
            return ""
        case .allFiles:
            return TextConstants.tabBarItemAllFilesLabel
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .plus:
            return UIImage(named: "")
        case .allFiles:
            return UIImage(named: "outlineDocs")
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .plus:
            return ""
        case .allFiles:
            return TextConstants.homeButtonAllFiles
        }
    }
}

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
        
        items[1].isEnabled = false
        
        setItems(items, animated: false)
    }
    
}
