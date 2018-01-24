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
        
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        button.setTitle(TextConstants.uploadFilesNextButton, for: .normal)
        button.setTitleColor(ColorConstants.whiteColor, for: .normal)
        button.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButton
    }
    
    
    override func selectedItemsCountChange(with count: Int) {
        super.selectedItemsCountChange(with: count)
        
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    ///need override this method for correct configuration UINavigationBar
    override func configureNavBarActions(isSelecting: Bool = false) {}

    @objc func onNextButton(){
        output.onNextButton()
    }
    
    var currentVC: UIViewController {
        return self//.navigationController?.popViewController(animated: true)
    }
}
