//
//  BaseFilesGreedChildrenViewController.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 7/24/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class BaseFilesGreedChildrenViewController: BaseFilesGreedViewController {
    
//    var viewTitle: String
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            navigationBarWithGradientStyle()

            if mainTitle != "" {
                self.subTitle = output.getSortTypeString()
            }
        
            self.setTitle(withString: mainTitle, andSubTitle: subTitle)
        
    }

    override func startSelection(with numberOfItems: Int) {
        configureNavBarActions(isSelecting: true)
        underNavBarBar?.setSorting(enabled: false)
        self.navigationItem.leftBarButtonItem = cancelSelectionButton!
    }
    
    override func stopSelection() {
        configureNavBarActions(isSelecting: false)
        underNavBarBar?.setSorting(enabled: true)
        self.navigationItem.leftBarButtonItem = nil
        if mainTitle != "" {
            self.subTitle = output.getSortTypeString()
        }
        self.setTitle(withString: mainTitle, andSubTitle: subTitle)
    }
    
    override func configurateNavigationBar() {
        configureNavBarActions()
    }
    
    override func isNeedShowTabBar() -> Bool{
        return needShowTabBar
    }
}
