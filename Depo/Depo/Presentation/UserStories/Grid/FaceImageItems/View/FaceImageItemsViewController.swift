//
//  FaceImageItemsViewController.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImageItemsViewController: BaseFilesGreedChildrenViewController {
    
    var isCanChangeVisibility: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle(withString: mainTitle )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configurateNavigationBar(){
        if (isCanChangeVisibility) {
            configurateFaceImagePeopleActions {
            }
        } else {
            navigationItem.rightBarButtonItems = nil
        }
        
    }

}
