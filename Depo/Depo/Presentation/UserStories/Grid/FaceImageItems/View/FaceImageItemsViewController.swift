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
        setTitle(withString: mainTitle )
        
        navigationBarWithGradientStyle()
        
        editingTabBar?.view.layoutIfNeeded()
        
        output.viewWillAppear()
        
        if let searchController = navigationController?.topViewController as? SearchViewController {
            searchController.dismissController(animated: false)
        }
    }

    //configuration navigationBar will be after receipt items
    override func configurateNavigationBar() { }
    
    override func stopSelection() {        
        if navigationItem.rightBarButtonItems != nil, isCanChangeVisibility {
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
        
        let done = NavBarWithAction(navItem: NavigationBarList().done, action: { [weak self] _ in
            self?.onApplySelection()
        })
        
        navBarConfigurator.configure(right: [done], left: [])
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }
}

// MARK: - FaceImageItemsViewInput

extension FaceImageItemsViewController: FaceImageItemsViewInput {
    
    func configurateUgglaView(hidden: Bool) {
        ugglaImageView = UIImageView(frame: CGRect(x: 0, y: view.bounds.size.height - ugglaViewHeight, width: view.bounds.size.width, height: ugglaViewHeight))
        ugglaImageView.isHidden = hidden
        ugglaImageView.contentMode = .center
        ugglaImageView.image = UIImage(named: "poweredByUggla")
        view.addSubview(ugglaImageView)
        
        ugglaImageView.translatesAutoresizingMaskIntoConstraints = false
        ugglaImageView.heightAnchor.constraint(equalToConstant: ugglaViewHeight).isActive = true
        ugglaImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ugglaImageView.widthAnchor.constraint(equalToConstant: view.bounds.size.width).isActive = true
        ugglaViewBottomConstraint = ugglaImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: ugglaViewHeight)
        ugglaViewBottomConstraint.isActive = true
        
        collectionView.contentInset.bottom = hidden ? 0 : ugglaViewHeight
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
    
    func showUgglaView() {
        ugglaImageView?.isHidden = false
        collectionView.contentInset.bottom = ugglaViewHeight
    }
    
    func hideUgglaView() {
        ugglaImageView?.isHidden = true
        collectionView.contentInset.bottom = 0
    }
    
    func showNoFilesWith(text: String, image: UIImage, createFilesButtonText: String, needHideTopBar: Bool, isShowUggla: Bool) {
        showNoFilesWith(text: text, image: image, createFilesButtonText: createFilesButtonText, needHideTopBar: needHideTopBar)
        noFilesTopLabel?.isHidden = true
        startCreatingFilesButton.isHidden = true
        if isShowUggla {
            ugglaImageView?.isHidden = true
        }
    }
    
    func updateShowHideButton(isShow: Bool) {
        if isCanChangeVisibility,
            isShow,
            navigationItem.rightBarButtonItems == nil {
            DispatchQueue.toMain {
                self.configurateFaceImagePeopleActions { [weak self] in
                    self?.configureDoneNavBarActions()
                }
            }
        }
    }
}
