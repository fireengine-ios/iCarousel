//
//  CustomEdinitgTabBar.swift
//  Depo
//
//  Created by Aleksandr on 6/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum AccessibilityImageType: String {
    case outlineHome
    case outlinePhotosVideos
    case outlineMusic
    case outlineDoc
}

typealias ImageNameToTitleTupple = (imageName: String, title: String, accessibilityTitle: String)

class CustomTabBar: UITabBar {
    
    func setupItems(withImageToTitleNames names: [ImageNameToTitleTupple]) {
        tintColor = ColorConstants.blueColor
        
        var items: [CustomTabBarItem] = []

        names.forEach { item in
            let tabBarItem: CustomTabBarItem = CustomTabBarItem(title: item.title.isEmpty ? nil : item.title,
                                                               image: UIImage(named: item.imageName),
                                                               tag: 0)
            
            tabBarItem.isAccessibilityElement = true

            if item.accessibilityTitle.count > 0 {
                tabBarItem.accessibilityLabel = item.accessibilityTitle
            }
        
            items.append(tabBarItem)
        }
        
        items[2].isEnabled = false
        
        if !Device.isIpad {
            for item in items {
                item.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            }
        }
        
        setItems(items, animated: false)
    }
    
}
