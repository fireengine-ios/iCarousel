//
//  FaceImageFilesViewController.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImageFilesViewController: BaseFilesGreedChildrenViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationTitle(title: mainTitle)
    }

    override func configureNavBarActions(isSelecting: Bool = false) {
        super.configureNavBarActions(isSelecting: isSelecting)
    }
}
