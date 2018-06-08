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
        super.viewDidAppear(animated)
    }
    
    override func configureNavBarActions(isSelecting: Bool = false) {
        navigationBarWithGradientStyle()        
        setTitle(withString: TextConstants.createStoryPhotosTitle)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.createStoryPhotosContinue,
                                                            target: self,
                                                            selector: #selector(onContinueButton))

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.createStoryPhotosCancel,
                                                           target: self,
                                                           selector: #selector(onCancelButton))
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
