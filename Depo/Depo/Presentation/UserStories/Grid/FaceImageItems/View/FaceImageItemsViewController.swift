//
//  FaceImageItemsViewController.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImageItemsViewController: BaseFilesGreedChildrenViewController {
    
    var isCanChangeVisibility: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle(withString: mainTitle )
    }

    override func configurateNavigationBar(){
        if (isCanChangeVisibility) {
            configurateFaceImagePeopleActions { [weak self] in
                self?.configureDoneNavBarActions()
            }
        } else {
            navigationItem.rightBarButtonItems = nil
        }
    }
    
    override func stopSelection() {
        if (isCanChangeVisibility) {
            configurateFaceImagePeopleActions { [weak self] in
                self?.configureDoneNavBarActions()
            }
        }
    }
    
    // MARK: - Configure navigation bar buttons
    
    private func onApplySelection() {
        if let output = output as? FaceImageItemsViewOutput {
            output.saveVisibilityChanges()
        }
    }
    
    private func configureDoneNavBarActions() {
        if let output = output as? FaceImageItemsViewOutput {
            output.switchVisibilityMode()
        }
        
        let done = NavBarWithAction(navItem: NavigationBarList().done, action: { [weak self] (_) in
            self?.onApplySelection()
        })
        
        navBarConfigurator.configure(right: [done], left: [])
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }

}
