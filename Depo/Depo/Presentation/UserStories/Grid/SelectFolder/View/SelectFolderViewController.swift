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
    
    let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
    let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
    let selectButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.setTitle(TextConstants.selectFolderCancelButton, for: .normal)
        cancelButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelButton), for: .touchUpInside)
        
        selectButton.setTitle(TextConstants.selectFolderNextButton, for: .normal)
        selectButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        selectButton.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)
        
        backButton.setTitle(TextConstants.selectFolderBackButton, for: .normal)
        backButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        backButton.addTarget(self, action: #selector(onBackButton), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarWithGradientStyle()
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        
        configureNavBarActions(isSelecting: false)
    }
    
    override func configureNavBarActions(isSelecting: Bool = false) {
        showRightButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.rightBarButtonItems = nil
        
        setTitle(withString: TextConstants.selectFolderTitle, andSubTitle: selectedFolder?.name)
        
        if (cancelSelectBlock != nil) {
            navigationItem.leftBarButtonItem = nil
            let barButtonLeft = UIBarButtonItem(customView: cancelButton)
            navigationItem.leftBarButtonItem = barButtonLeft
        }

        showRightButton()
    }
    
    func showRightButton() {
        
        let barButtonRight = UIBarButtonItem(customView: selectButton)
        
        navigationItem.rightBarButtonItem = barButtonRight
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
