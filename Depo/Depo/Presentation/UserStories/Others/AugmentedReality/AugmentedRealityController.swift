//
//  AugumentRealityDetailViewController.swift
//  Depo
//
//  Created by Konstantin on 8/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import QuickLook


final class AugmentedRealityController: QLPreviewController {
    
    var source: AugmentedRealityDataSource!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = source
    }
}

