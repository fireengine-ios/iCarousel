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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle(withString: mainTitle)
    }

    override func startSelection(with numberOfItems: Int) {
        configureNavBarActions(isSelecting: true)
        selectedItemsCountChange(with: numberOfItems)
        underNavBarBar?.setSorting(enabled: false)
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.leftBarButtonItem = cancelSelectionButton
        if status.isContained(in: [.hidden, .trashed]) {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func stopSelection() {
        underNavBarBar?.setSorting(enabled: true)
        
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.leftBarButtonItem = nil
    
        setTitle(withString: mainTitle)
        configureNavBarActions(isSelecting: false)
    }

    override func configurateNavigationBar() {
        configureNavBarActions()
    }
}
