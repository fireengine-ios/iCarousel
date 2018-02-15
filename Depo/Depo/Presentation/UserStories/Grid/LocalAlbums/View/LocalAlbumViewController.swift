//
//  LocalAlbumViewController.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LocalAlbumViewController: BaseFilesGreedChildrenViewController {
    
    let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.setTitle(TextConstants.selectFolderCancelButton, for: .normal)
        cancelButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelButton), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBarActions()
    }
    
    override func configureNavBarActions(isSelecting: Bool = false) {
        visibleNavigationBarStyle()
        setNavigationTitle(title: mainTitle)

        let barButtonLeft = UIBarButtonItem(customView: cancelButton)
        navigationItem.leftBarButtonItem = barButtonLeft
        navigationItem.rightBarButtonItems = nil
    }
    
    @objc func onCancelButton(){
        output.moveBack()
    }
    
}

