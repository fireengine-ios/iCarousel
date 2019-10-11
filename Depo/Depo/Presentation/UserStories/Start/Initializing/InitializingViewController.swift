//
//  InitializingViewController.swift
//  Depo
//
//  Created by Konstantin Studilin on 11/10/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class InitializingViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSpinner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideSpinner()
    }

}
