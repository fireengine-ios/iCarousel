//
//  LocalAlbumViewController.swift
//  Depo_LifeTech
//
//  Created by Tsimafei Harhun on 11/21/17.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class LocalAlbumViewController: BaseFilesGreedChildrenViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.selectFolderCancelButton,
                                                           target: self,
                                                           selector: #selector(onCancelButton))
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
    
    override func loadData() {
        output.onReloadData()
        contentSlider?.reloadAllData()
        refresher.endRefreshing()
    }
}
