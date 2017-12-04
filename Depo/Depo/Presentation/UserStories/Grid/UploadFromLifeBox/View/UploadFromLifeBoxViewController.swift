//
//  UploadFromLifeBoxUploadFromLifeBoxViewController.swift
//  Depo
//
//  Created by Oleg on 01/12/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class UploadFromLifeBoxViewController: BaseFilesGreedViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBarActions()
    }
    
    override func configureNavBarActions(){
        navigationBarWithGradientStyle()
        setTitle(withString: TextConstants.uploadFromLifeBoxTitle)
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        button.setTitle(TextConstants.uploadFromLifeBoxNextButton, for: .normal)
        button.setTitleColor(ColorConstants.whiteColor, for: .normal)
        button.addTarget(self, action: #selector(onNextButton), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: button)
        
        navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func onNextButton(){
        output.onNextButton()
    }
    
    override func isNeedShowTabBar() -> Bool{
        return false
    }
    
}
