//
//  SharedAreaViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 22.12.20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class SharedAreaViewController: BaseViewController, NibInit {

    override func viewDidLoad() {
        super.viewDidLoad()

        isTabBarItem = true
        needToShowTabBar = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        whiteNavBarStyle(isLargeTitle: false)
    }

}

