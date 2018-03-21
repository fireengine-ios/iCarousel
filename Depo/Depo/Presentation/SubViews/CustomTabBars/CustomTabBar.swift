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

typealias ImageNameToTitleTupple = (imageName: String, title: String)

class CustomTabBar: UITabBar {
    
    func setupItems(withImageToTitleNames names: [ImageNameToTitleTupple]) {

        tintColor = ColorConstants.blueColor
        let items = names.map {CustomTabBarItem(title: $0.title.isEmpty ? nil : $0.title,
                                                   image: UIImage(named: $0.imageName),
                                                   tag: 0)
        }
        items[2].isEnabled = false
        
        if !Device.isIpad {
            for item in items {
                item.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            }
        }
        
        items.forEach { item in
            guard let image = item.image else {
                return
            }
            item.isAccessibilityElement = true
            
            if image.isEqual(UIImage(named: AccessibilityImageType.outlineHome.rawValue)) {
                item.accessibilityLabel = TextConstants.accessibilityHome
            } else if image.isEqual(UIImage(named: AccessibilityImageType.outlinePhotosVideos.rawValue)) {
                item.accessibilityLabel = TextConstants.accessibilityPhotosVideos
            } else if image.isEqual(UIImage(named: AccessibilityImageType.outlineMusic.rawValue)) {
                item.accessibilityLabel = TextConstants.accessibilityMusic
            } else if image.isEqual(UIImage(named: AccessibilityImageType.outlineDoc.rawValue)) {
                item.accessibilityLabel = TextConstants.accessibilityDocuments
            } else {
                item.accessibilityLabel = item.title
            }
        }
        
        setItems(items, animated: false)
    }
    
}
