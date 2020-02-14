//
//  UploadFromLifeBoxUploadFromLifeBoxViewController.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadFromLifeBoxViewController: BaseFilesGreedChildrenViewController, UploadFromLifeBoxViewInput {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollablePopUpView.isEnable = false
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationItem.leftBarButtonItem == nil, navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.selectFolderCancelButton,
                                                               target: self,
                                                               selector: #selector(onCancelButton))
        }
    }
    
    override func configureNavBarActions(isSelecting: Bool = false) {
        setTitle(withString: TextConstants.uploadFromLifeBoxTitle)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.uploadFromLifeBoxNextButton,
                                                            target: self,
                                                            selector: #selector(onNextButton))
    }
    
    /// don't remove
    override func setThreeDotsMenu(active isActive: Bool)  {}
    
    @objc func onNextButton() {
        output.onNextButton()
    }
    
    @objc func onCancelButton() {
        hideView()
    }
    
    func hideView() {
        dismiss(animated: true, completion: nil)
    }
    
    override func isNeedToShowTabBar() -> Bool {
        return false
    }
    
    override func stopSelection() {
        super.stopSelection()
        
        setTitle(withString: TextConstants.uploadFromLifeBoxTitle)
        if navigationItem.leftBarButtonItem == nil, navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: TextConstants.selectFolderCancelButton,
                target: self,
                selector: #selector(onCancelButton))
        }
    }
    
    override func showNoFilesWith(text: String, image: UIImage, createFilesButtonText: String, needHideTopBar: Bool) {
        super.showNoFilesWith(text: text, image: image, createFilesButtonText: createFilesButtonText, needHideTopBar: needHideTopBar)
        
        startCreatingFilesButton.isHidden = true
    }
    
    func getNavigationController() -> UINavigationController? {
        return navigationController
    }
    
    func getDestinationUUID() -> String {
        return parentUUID
    }
    
    func showOutOfSpaceAlert() {
        let controller = FullQuotaWarningPopUp()

        dismiss(animated: true, completion: {
            UIApplication.topController()?.present(controller, animated: false, completion: nil)
        })
    }
}
