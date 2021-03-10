//
//  AgreementsViewController.swift
//  Depo_LifeTech
//
//  Created by Vyacheslav Bakinskiy on 10.03.21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class AgreementsViewController: BaseViewController, NibInit {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(withString: TextConstants.agreements)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !Device.isIpad {
            defaultNavBarStyle()
        }
    }
}
