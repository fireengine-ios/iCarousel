//
//  BaseFilesGreedChildrenViewController.swift
//  Depo_LifeTech
//
//  Created by Alexander Gurin on 7/24/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation

class BaseFilesGreedChildrenViewController: BaseFilesGreedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultNavBarStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if parent is SegmentedController {
            defaultNavBarStyle()
            
        } else {
            defaultNavBarStyle()
            
        }
        
        if mainTitle != "" {
            subTitle = output.getSortTypeString()
        }
        
        setTitle(withString: mainTitle, andSubTitle: subTitle)
    }

    override func startSelection(with numberOfItems: Int) {
        configureNavBarActions(isSelecting: true)
        selectedItemsCountChange(with: numberOfItems)
        underNavBarBar?.setSorting(enabled: false)
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.leftBarButtonItem = cancelSelectionButton
        if status.isContained(in: [.trashed]) {
            navigationItem.rightBarButtonItem = nil
        }
        defaultNavBarStyle()
    }
    
    override func stopSelection() {
        underNavBarBar?.setSorting(enabled: true)
        
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.leftBarButtonItem = nil
        
        if mainTitle != "" {
            subTitle = output.getSortTypeString()
        }
        setTitle(withString: mainTitle, andSubTitle: subTitle)
        
        defaultNavBarStyle()
        
        configureNavBarActions(isSelecting: false)
    }

    override func configurateNavigationBar() {
        configureNavBarActions()
    }
    
    override func isNeedToShowTabBar() -> Bool {
        return needToShowTabBar
    }
}
