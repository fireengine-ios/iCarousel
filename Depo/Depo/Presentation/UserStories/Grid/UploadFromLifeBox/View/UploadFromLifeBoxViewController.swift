//
//  UploadFromLifeBoxUploadFromLifeBoxViewController.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadFromLifeBoxViewController: BaseFilesGreedChildrenViewController, UploadFromLifeBoxViewInput {
    
    let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.setTitle(TextConstants.selectFolderCancelButton, for: .normal)
        cancelButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelButton), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrolliblePopUpView.isEnable = false
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationItem.leftBarButtonItem == nil && navigationController?.viewControllers.count == 1 {
            let barButtonLeft = UIBarButtonItem(customView: cancelButton)
            navigationItem.leftBarButtonItem = barButtonLeft
        }
    }
    
    override func configureNavBarActions(isSelecting: Bool = false) {
        setTitle(withString: TextConstants.uploadFromLifeBoxTitle)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        button.setTitle(TextConstants.uploadFromLifeBoxNextButton, for: .normal)
        button.setTitleColor(ColorConstants.whiteColor, for: .normal)
        button.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)

        let barButton = UIBarButtonItem(customView: button)

        navigationItem.rightBarButtonItem = barButton
    }
    
    override func setThreeDotsMenu(active isActive: Bool)  {
        
    }
    
    @objc func onNextButton() {
        output.onNextButton()
    }
    
    @objc func onCancelButton() {
        hideView()
    }
    
    func hideView() {
        dismiss(animated: true) {
            
        }
    }
    
    override func isNeedShowTabBar() -> Bool {
        return false
    }
    
    override func stopSelection() {
        super.stopSelection()
        
        setTitle(withString: TextConstants.uploadFromLifeBoxTitle)
        if navigationItem.leftBarButtonItem == nil && navigationController?.viewControllers.count == 1 {
            let barButtonLeft = UIBarButtonItem(customView: cancelButton)
            navigationItem.leftBarButtonItem = barButtonLeft
        }
    }
    
    func getNavigationController() -> UINavigationController? {
        return navigationController
    }
    
    func getDestinationUUID() -> String {
        return parentUUID
    }
    
}
