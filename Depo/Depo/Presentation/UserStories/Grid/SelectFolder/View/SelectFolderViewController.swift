//
//  SelectFolderViewController.swift
//  Depo
//
//  Created by Oleg on 07/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

typealias SelectFolder = (_ folderID: String) -> Void
typealias CancelSelectFolder = () -> Void

class SelectFolderViewController: BaseFilesGreedChildrenViewController {
    
    var selectFolderBlock: SelectFolder?
    var cancelSelectBlock: CancelSelectFolder?
    var selectedFolder: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationBarWithGradientStyle()
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        
        configureNavBarActions(isSelecting: false)
        
        setTitle(withString: TextConstants.selectFolderTitle, andSubTitle: nil)
    }
    
    override func configureNavBarActions(isSelecting: Bool = false) {
        showRightButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.rightBarButtonItems = nil
        
        if (cancelSelectBlock != nil) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.selectFolderCancelButton,
                                                               target: self,
                                                               selector: #selector(onCancelButton))
        }

        showRightButton()
    }
    
    func showRightButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.selectFolderNextButton,
                                                            target: self,
                                                            selector: #selector(onNextButton))
    }
    
    @objc func onNextButton() {
        output.onNextButton()
    }
    
    @objc func onCancelButton() {
        cancelSelectBlock?()
        hide()
    }
    
    func hide() {
        dismiss(animated: true, completion: nil)
    }
    
    func selectFolder(select: @escaping SelectFolder, cancel: @escaping CancelSelectFolder) {
        selectFolderBlock = select
        cancelSelectBlock = cancel
        
        let router = RouterVC()
        let nContr = NavigationController(rootViewController: self)
        nContr.navigationBar.isHidden = false
        router.presentViewController(controller: nContr)
    }
    
    func onFolderSelected(folderID: String) {
        selectFolderBlock?(folderID)
        hide()
    }
}
