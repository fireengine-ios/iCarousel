//
//  CustomEdinitgTabBar.swift
//  Depo
//
//  Created by Aleksandr on 6/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum TabBarItem: CaseIterable {
    case home
    case gallery
    case plus
    case contacts
    case allFiles
    
    var title: String {
        switch self {
        case .home:
            return TextConstants.tabBarItemHomeLabel
        case .gallery:
            return TextConstants.tabBarItemGalleryLabel
        case .plus:
            return ""
        case .contacts:
            return TextConstants.tabBarItemContactsLabel
        case .allFiles:
            return TextConstants.tabBarItemAllFilesLabel
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "outlineHome")
        case .gallery:
            return UIImage(named: "outlinePhotosVideos")
        case .plus:
            return UIImage(named: "")
        case .contacts:
            return UIImage(named: "outlineMusic")
        case .allFiles:
            return UIImage(named: "outlineDoc")
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .home:
            return TextConstants.accessibilityHome
        case .gallery:
            return TextConstants.accessibilityPhotosVideos
        case .plus:
            return ""
        case .contacts:
            return TextConstants.periodicContactsSync
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
            if !Device.isIpad && !Device.isIOS13 {
                tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            }
            
            return tabBarItem
        }
        
        items[2].isEnabled = false
        
        setItems(items, animated: false)
    }
    
}
