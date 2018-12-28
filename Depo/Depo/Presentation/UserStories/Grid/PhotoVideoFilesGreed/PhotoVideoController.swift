//
//  PhotoVideoController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 10/19/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PhotoVideoController: BaseFilesGreedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        underNavBarBar?.setSorting(enabled: false)
    }
    
    /// removed from super:
    ///underNavBarBar?.setSorting(enabled: true)
    override func stopSelection() {
        self.navigationItem.leftBarButtonItem = nil
        homePageNavigationBarStyle()
        configureNavBarActions(isSelecting: false)
    }
}
