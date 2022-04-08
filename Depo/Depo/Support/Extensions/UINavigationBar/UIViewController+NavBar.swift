//
//  UIViewController+NavBar.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/18/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

// TODO: Facelift: didn't see a screen with subtitle in the new designs. This can be dropped maybe?
extension UIViewController {
    func setTitle(withString title: String, andSubTitle subTitle: String? = nil) {
        if let subTitle = subTitle {
            navigationItem.title = nil

            let customTitleView = TitleView.initFromXib()
            customTitleView.setTitle(title)
            customTitleView.setSubTitle(subTitle)

            navigationItem.titleView = customTitleView

            #if MAIN_APP
            if let viewController = self as? ViewController {
                customTitleView.updateColors(for: viewController.preferredNavigationBarStyle)
            }
            #endif
        } else {
            navigationItem.titleView = nil
            navigationItem.title = title
        }
    }
}
