//
//  FaceImageItemPhotosViewController.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImagePhotosViewController: BaseFilesGreedChildrenViewController, FaceImagePhotosViewInput {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mainTitle.count == 0 {
            mainTitle = TextConstants.faceImageAddName
        }
        
        configureTitleNavigationBar()
    }
    
    override func  configurateNavigationBar() {
        configureFaceImageItemsPhotoActions()
    }
    
    override func stopSelection() {
        super.stopSelection()
        
        configureFaceImageItemsPhotoActions()
        setTitle(withString: mainTitle)
    }
    
    @objc func addNameAction() {
        if let output = output as? FaceImagePhotosViewOutput {
            output.openAddName()
        }
    }
    
    private func configureTitleNavigationBar() {
        setTouchableTitle(title: mainTitle)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.addNameAction))
        navigationItem.titleView?.addGestureRecognizer(tap)
    }
    
    // MARK: - FaceImagePhotosViewInput
    
    func reloadName(_ name: String) {
        mainTitle = name
        
        setTitle(withString: mainTitle)
    }

}
