//
//  CustomEdinitgTabBar.swift
//  Depo
//
//  Created by Aleksandr on 6/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

typealias ImageNameToTitleTupple = (imageName : String, title: String)

class CustomTabBar: UITabBar {
    
    func setupItems(withImageToTitleNames names: [ImageNameToTitleTupple]) {

        tintColor = ColorConstants.blueColor
        let items = names.map{ CustomTabBarItem(title: $0.title,
                                                   image: UIImage(named:$0.imageName),
                                                   tag: 0)
        }
        items[2].isEnabled = false
        setItems(items, animated: false)
    }
    
}
