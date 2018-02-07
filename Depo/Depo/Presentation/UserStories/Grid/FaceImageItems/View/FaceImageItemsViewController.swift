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

    override func configurateNavigationBar(){
        if (isCanChangeVisibility) {
            configurateFaceImagePeopleActions { [weak self] in
                self?.configureApplyNavBarActions()
            }
        } else {
            navigationItem.rightBarButtonItems = nil
        }
    }
    
    override func stopSelection() {
        configurateFaceImagePeopleActions { [weak self] in
            self?.configureApplyNavBarActions()
        }
    }
    
    // MARK: - Configure navigation bar buttons
    
    private func onApplySelection() {
        if let output = output as? FaceImageItemsViewOutput {
            output.saveVisibilityChanges()
        }
    }
    
    private func configureApplyNavBarActions() {
        if let output = output as? FaceImageItemsViewOutput {
            output.switchVisibilityMode()
        }
        
        let apply = NavBarWithAction(navItem: NavigationBarList().apply, action: { [weak self] (_) in
            self?.onApplySelection()
        })
        navBarConfigurator.configure(right: [apply], left: [])
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }

}
