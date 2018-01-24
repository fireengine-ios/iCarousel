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
        selectedItemsCountChange(with: numberOfItems)
        underNavBarBar?.setSorting(enabled: false)
        navigationItem.leftBarButtonItem = cancelSelectionButton!
    }
    
    override func stopSelection() {
        configureNavBarActions(isSelecting: false)
        underNavBarBar?.setSorting(enabled: true)
        navigationItem.leftBarButtonItem = nil
        if mainTitle != "" {
            subTitle = output.getSortTypeString()
        }
        setTitle(withString: mainTitle, andSubTitle: subTitle)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func configurateViewForPopUp() {
        scrolliblePopUpView.isEnable = false
    }

    override func configurateNavigationBar() {
        configureNavBarActions()
    }
    
    override func isNeedShowTabBar() -> Bool{
        return needShowTabBar
    }
    
}
