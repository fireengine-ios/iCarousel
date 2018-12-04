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
//        navigationBarWithGradientStyle()
        homePageNavigationBarStyle()
    }
    
    override func configureNavBarActions(isSelecting: Bool = false) {
        super.configureNavBarActions(isSelecting: isSelecting)
//        defaultNavBarStyle()
//        navigationBarWithGradientStyle()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationBarWithGradientStyle()
//        homePageNavigationBarStyle()
        
        if let _ = parent as? SegmentedController {
            homePageNavigationBarStyle()
        } else {
            navigationBarWithGradientStyle()
        }
        
        if mainTitle != "" {
            subTitle = output.getSortTypeString()
        }
        
        setTitle(withString: mainTitle, andSubTitle: subTitle)
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.title = mainTitle
    }

    override func startSelection(with numberOfItems: Int) {
        configureNavBarActions(isSelecting: true)
        selectedItemsCountChange(with: numberOfItems)
        underNavBarBar?.setSorting(enabled: false)
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.leftBarButtonItem = cancelSelectionButton!
        navigationBarWithGradientStyle()
    }
    
    override func stopSelection() {
        configureNavBarActions(isSelecting: false)
        underNavBarBar?.setSorting(enabled: true)
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.leftBarButtonItem = nil
        navigationItem.title = mainTitle
        if mainTitle != "" {
            subTitle = output.getSortTypeString()
        }
        setTitle(withString: mainTitle, andSubTitle: subTitle)
//        homePageNavigationBarStyle()
        
        if let _ = parent as? SegmentedController {
            homePageNavigationBarStyle()
        } else {
            navigationBarWithGradientStyle()
        }
    }

    override func configurateNavigationBar() {
        configureNavBarActions()
    }
    
    override func isNeedShowTabBar() -> Bool {
        return needShowTabBar
    }
    
}
