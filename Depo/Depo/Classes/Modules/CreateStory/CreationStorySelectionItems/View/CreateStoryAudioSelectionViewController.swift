//
//  CreateStoryAudioSelectionViewController.swift
//  Depo
//
//  Created by Oleg on 02.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CreateStoryAudioSelectionViewController: BaseFilesGreedChildrenViewController {
    
    let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
    let selectButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTitle = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBarActions()
    }
    
    override func configureNavBarActions(){
        navigationBarWithGradientStyle()
        setTitle(withString: TextConstants.createStoryAudioSelected)
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = nil
        
        cancelButton.setTitle(TextConstants.selectFolderCancelButton, for: .normal)
        cancelButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelButton), for: .touchUpInside)
        
        selectButton.setTitle(TextConstants.createStorySelectAudioButton, for: .normal)
        selectButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        selectButton.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)
        
        let barButtonRight = UIBarButtonItem(customView: selectButton)
        let barButtonLeft = UIBarButtonItem(customView: cancelButton)
        
        navigationItem.rightBarButtonItem = barButtonRight
        navigationItem.leftBarButtonItem = barButtonLeft
    }
    
    @objc func onNextButton(){
        output.onNextButton()
    }
    
    @objc func onCancelButton(){
        hideView()
    }
    
    func hideView(){
        dismiss(animated: true) {
            
        }
    }
    
    override func isNeedShowTabBar() -> Bool{
        return false
    }
    
}
