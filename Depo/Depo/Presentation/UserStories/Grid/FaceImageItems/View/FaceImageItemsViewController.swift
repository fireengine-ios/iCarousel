//
//  FaceImageItemsViewController.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class FaceImageItemsViewController: BaseFilesGreedChildrenViewController {
    
    private let ugglaViewHeight: CGFloat = 50
    
    private var ugglaImageView: UIImageView!
    private var ugglaViewBottomConstraint: NSLayoutConstraint!
    
    var isCanChangeVisibility: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle(withString: mainTitle )
    }

    override func configurateNavigationBar() {
        if (isCanChangeVisibility) {
            configurateFaceImagePeopleActions { [weak self] in
                self?.configureDoneNavBarActions()
            }
        } else {
            navigationItem.rightBarButtonItems = nil
        }
    }
    
    override func stopSelection() {
        if (isCanChangeVisibility) {
            configurateFaceImagePeopleActions { [weak self] in
                self?.configureDoneNavBarActions()
            }
        }
    }
    
    // MARK: - Configure navigation bar buttons
    
    private func onApplySelection() {
        if let output = output as? FaceImageItemsViewOutput {
            output.saveVisibilityChanges()
        }
    }
    
    private func configureDoneNavBarActions() {
        if let output = output as? FaceImageItemsViewOutput {
            output.switchVisibilityMode()
        }
        
        let done = NavBarWithAction(navItem: NavigationBarList().done, action: { [weak self] (_) in
            self?.onApplySelection()
        })
        
        navBarConfigurator.configure(right: [done], left: [])
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }
    
    // MARK: - FaceImageItemsInput

}

//MARK: - FaceImageItemsViewInput

extension FaceImageItemsViewController: FaceImageItemsViewInput {
    
    func configurateUgglaView() {
        ugglaImageView = UIImageView(frame: CGRect(x: 0, y: view.bounds.size.height - ugglaViewHeight, width: view.bounds.size.width, height: ugglaViewHeight))
        ugglaImageView.contentMode = .center
        ugglaImageView.image = UIImage(named: "poweredByUggla")
        view.addSubview(ugglaImageView)
        
        ugglaImageView.translatesAutoresizingMaskIntoConstraints = false
        ugglaImageView.heightAnchor.constraint(equalToConstant: ugglaViewHeight).isActive = true
        ugglaImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ugglaImageView.widthAnchor.constraint(equalToConstant: view.bounds.size.width).isActive = true
        ugglaViewBottomConstraint = ugglaImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: ugglaViewHeight)
        ugglaViewBottomConstraint.isActive = true
        
        collectionView.contentInset.bottom = ugglaViewHeight
    }
    
    func updateUgglaViewPosition() {
        let contentHeight = collectionView.contentSize.height
        
        if contentHeight < collectionView.frame.height - ugglaViewHeight {
            ugglaViewBottomConstraint.constant = 0
        } else {
            let yOffset = collectionView.contentOffset.y
            let delta = contentHeight - yOffset - collectionView.frame.height
            
            if delta < 0 && abs(delta) <= ugglaViewHeight {
                ugglaViewBottomConstraint.constant = ugglaViewHeight - abs(delta)
            } else if delta < -ugglaViewHeight {
                ugglaViewBottomConstraint.constant = 0
            } else {
                ugglaViewBottomConstraint.constant = ugglaViewHeight
            }
        }
        view.layoutIfNeeded()
    }
    
    func showNoFilesWith(text: String, image: UIImage, createFilesButtonText: String, needHideTopBar: Bool, isShowUggla: Bool) {
        super.showNoFilesWith(text: text, image: image, createFilesButtonText: createFilesButtonText, needHideTopBar: needHideTopBar)
        startCreatingFilesButton.isHidden = true
        noFilesTopLabel?.isHidden = true
        isCanChangeVisibility = false
        if isShowUggla {
            ugglaImageView.isHidden = true
        }
    }
    
}
