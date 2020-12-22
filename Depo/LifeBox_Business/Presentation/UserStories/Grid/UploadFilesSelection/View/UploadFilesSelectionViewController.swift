//
//  UploadFilesSelectionUploadFilesSelectionViewController.swift
//  Depo
//
//  Created by Oleg on 04/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadFilesSelectionViewController: BaseFilesGreedChildrenViewController, UploadFilesSelectionViewInput {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.rightBarButtonItems = NavigationBarConfigurator().rightItems

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.uploadFilesNextButton,
                                                            target: self,
                                                            selector: #selector(onNextButton))
    }
    
    override func selectedItemsCountChange(with count: Int) {
        super.selectedItemsCountChange(with: count)
        
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    ///need override this method for correct configuration UINavigationBar
    override func configureNavBarActions(isSelecting: Bool = false) {}

    @objc func onNextButton() {
        output.onNextButton()
    }
}
