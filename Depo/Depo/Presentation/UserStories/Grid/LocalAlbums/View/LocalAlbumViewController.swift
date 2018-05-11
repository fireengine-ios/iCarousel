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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.setTitle(TextConstants.selectFolderCancelButton, for: .normal)
        cancelButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelButton), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onLocalFilesHaveBeenLoaded),
                                               name: Notification.Name.allLocalMediaItemsHaveBeenLoaded,
                                               object: nil)
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
    
    override func showNoFilesWith(text: String, image: UIImage, createFilesButtonText: String, needHideTopBar: Bool) {
        super.showNoFilesWith(text: TextConstants.haveNoAnyFiles , image: image, createFilesButtonText: createFilesButtonText, needHideTopBar: needHideTopBar)
        startCreatingFilesButton.isHidden = true
    }
    
    @objc func onCancelButton() {
        output.moveBack()
    }
    
    @objc func onLocalFilesHaveBeenLoaded() {
        output.onReloadData()
    }
    
}
