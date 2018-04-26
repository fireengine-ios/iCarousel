//
//  FloatingContainerVC.swift
//  Depo
//
//  Created by Aleksandr on 9/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class FloatingContainerVC: UIViewController, UIPopoverPresentationControllerDelegate {
    
    let offsetBox = CGRect(x: 0, y: 10, width: 5, height: 5)
    
    static func createContainerVC(withContentView contentView: UIViewController,
                                  sourceView: UIView,
                                  popOverSize: CGSize) -> FloatingContainerVC {
        let floatingContainerVC = FloatingContainerVC(nibName: nil, bundle: nil)
        
        floatingContainerVC.addChildViewController(contentView)
        floatingContainerVC.view.addSubview(contentView.view)
        floatingContainerVC.preferredContentSize = popOverSize
        
        floatingContainerVC.setupContentView(withView: contentView.view)
  
        floatingContainerVC.modalPresentationStyle = .popover
        floatingContainerVC.popoverPresentationController?.sourceView = sourceView
        floatingContainerVC.popoverPresentationController?.sourceRect = floatingContainerVC.offsetBox
        floatingContainerVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        
        floatingContainerVC.popoverPresentationController?.delegate = floatingContainerVC
        
        return floatingContainerVC
    }
    
    func setupContentView(withView contentView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let horisontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[contentView]-(0)-|",
                                                                   options: [], metrics: nil,
                                                                   views: ["contentView" : contentView])
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[contentView]-(0)-|",
                                                                 options: [], metrics: nil,
                                                                 views: ["contentView" : contentView])
        view.addConstraints(horisontalConstraints + verticalConstraints)
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        childViewControllers.forEach({ $0.removeFromParentViewController() })
        return true
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
