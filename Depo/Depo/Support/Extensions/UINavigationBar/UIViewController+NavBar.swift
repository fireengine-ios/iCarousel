//
//  UIViewController+NavBar.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/18/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

extension UIViewController {
    func setTitle(withString title: String, andSubTitle subTitle: String? = nil) {
        if let subTitle = subTitle {
            navigationItem.title = nil

            let customTitleView = TitleView.initFromXib()
            customTitleView.setTitle(title)
            customTitleView.setSubTitle(subTitle)

            navigationItem.titleView = customTitleView
        } else {
            navigationItem.titleView = nil
            navigationItem.title = title
        }
    }
}
