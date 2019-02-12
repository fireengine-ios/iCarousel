//
//  CreateStoryAudioSelectionViewController.swift
//  Depo
//
//  Created by Oleg on 02.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CreateStoryAudioSelectionViewController: BaseFilesGreedChildrenViewController {
    @IBOutlet weak var segmentControll: UISegmentedControl!
    @IBOutlet weak var topIOS10Contraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTitle = ""
        
        segmentControll.setTitle(TextConstants.createStoryAudioMusics, forSegmentAt: 0)
        segmentControll.setTitle(TextConstants.createStoryAudioYourUploads, forSegmentAt: 1)
        segmentControll.tintColor = ColorConstants.darkBlueColor
        
        collectionView.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            view.removeConstraint(topIOS10Contraint)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBarActions()
    }
    
    override func configureNavBarActions(isSelecting: Bool = false) {
        navigationBarWithGradientStyle()
        setTitle(withString: TextConstants.createStoryAudioSelected)
                
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.createStorySelectAudioButton,
                                                            target: self,
                                                            selector: #selector(onNextButton))

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.selectFolderCancelButton,
                                                           target: self,
                                                           selector: #selector(onCancelButton))
    }
    
    @objc func onNextButton() {
        output.onNextButton()
    }
    
    @objc func onCancelButton() {
        hideView()
    }
    
    func hideView() {
        dismiss(animated: true, completion: nil)
    }
    
    override func isNeedShowTabBar() -> Bool {
        return false
    }
    
    @IBAction func segmentControlValueChanged(sender: UISegmentedControl) {
        if let presenter = output as? CreateStoryAudioSelectionPresenter {
            presenter.onChangeSource(isYourUpload: sender.selectedSegmentIndex == 1)
        }
    }
    
}
