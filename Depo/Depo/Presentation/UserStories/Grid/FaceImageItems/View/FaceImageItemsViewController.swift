//
//  FaceImageItemsViewController.swift
//  Depo
//
//  Created by Harbros on 29.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol FaceImageItemsInput: class {
    func scrollViewDidScroll(scrollView: UIScrollView)
    func configurateUgglaView()
}

final class FaceImageItemsViewController: BaseFilesGreedChildrenViewController, FaceImageItemsInput {
    
    private let ugglaViewHeight: CGFloat = 50
    
    private var ugglaImageView: UIImageView!
    private var ugglaViewBottomConstraint: NSLayoutConstraint!
    
    var isCanChangeVisibility: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTitle(withString: mainTitle )
    }

    override func configurateNavigationBar(){
        if (isCanChangeVisibility) {
            configurateFaceImagePeopleActions { [weak self] in
                self?.configureDoneNavBarActions()
            }
        } else {
            navigationItem.rightBarButtonItems = nil
        }
    }
    
    override func stopSelection() {
        configurateFaceImagePeopleActions { [weak self] in
            self?.configureDoneNavBarActions()
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
    
    //MARK: - FaceImageItemsInput
    
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == collectionView {
            let contentHeight = scrollView.contentSize.height
            
            if contentHeight < scrollView.frame.height - ugglaViewHeight {
                ugglaViewBottomConstraint.constant = 0
            } else {
                let yOffset = scrollView.contentOffset.y
                let delta = contentHeight - yOffset - scrollView.frame.height

                if delta < 0 && abs(delta) < ugglaViewHeight {
                    ugglaViewBottomConstraint.constant = ugglaViewHeight - abs(delta)
                } else if delta < -ugglaViewHeight {
                    ugglaViewBottomConstraint.constant = 0
                } else {
                    ugglaViewBottomConstraint.constant = ugglaViewHeight
                }
            }
            view.layoutIfNeeded()
        }
    }

}
