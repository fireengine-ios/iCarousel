//
//  CreateStoryPhotoSelectionViewController.swift
//  Depo
//
//  Created by Oleg on 02.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CreateStoryPhotoSelectionViewController: BaseFilesGreedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MenloworksAppEvents.onCreateStoryPageOpen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configurateNavigationBar()
        configurateViewForPopUp()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func configureNavBarActions(isSelecting: Bool = false) {
        navigationBarWithGradientStyle()        
        setTitle(withString: TextConstants.createStoryPhotosTitle)
        
        let continueButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        continueButton.setTitle(TextConstants.createStoryPhotosContinue, for: .normal)
        continueButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        continueButton.addTarget(self, action: #selector(onContinueButton), for: .touchUpInside)
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        cancelButton.setTitle(TextConstants.createStoryPhotosCancel, for: .normal)
        cancelButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelButton), for: .touchUpInside)
        
        let rightBarButton = UIBarButtonItem(customView: continueButton)
        let leftBarButton = UIBarButtonItem(customView: cancelButton)
        
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    override func selectedItemsCountChange(with count: Int) {
        if count > 0 {
            super.selectedItemsCountChange(with: count)
        } else {
            setTitle(withString: TextConstants.createStoryPhotosTitle)
        }
    }

    @objc func onContinueButton() {
        output.onNextButton()
    }
    
    @objc func onCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    override func isNeedShowTabBar() -> Bool {
        return false
    }
}
