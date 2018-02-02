//
//  FaceImageItemsViewController.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImageItemsViewController: BaseFilesGreedChildrenViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(title: mainTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configurateNavigationBar(){
        configurateFaceImageItemsActions {
            
        }
    }

}
