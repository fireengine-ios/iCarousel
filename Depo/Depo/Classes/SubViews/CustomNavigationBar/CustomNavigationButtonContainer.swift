//
//  CustomNavigationButtonContainer.swift
//  Depo
//
//  Created by Aleksandr on 6/22/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol CustomNavigationButtonContainerActionsDelegate: class {
    func buttonGotPressed(withCustomButton customNavButton: CustomNavBarButton)
}

class CustomNavigationButtonContainer: UIView {
    
    weak var actionDelegate: CustomNavigationButtonContainerActionsDelegate?
    
    var buttons:[CustomNavBarButton] = []
    
    func addButton(withImageName imageName: String) {
        let button = CustomNavBarButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.btnName = imageName
        button.addTarget(self, action: #selector(buttonAction(withSender:)), for: .touchUpInside)
//        button.backgroundColor = UIColor.brown
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        setupConstraints(forButton: button)
        buttons.append(button)
    }
    
    private func setupConstraints(forButton button: CustomNavBarButton) {
        button.setSize(withWidth: 45, withHeight: 45)

        let centerYconstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: button, attribute: .centerY, multiplier: 1, constant: 0)
        
        var constraintOffset: CGFloat = 5
        if let lastObject = buttons.last {
            constraintOffset += lastObject.btnSize.width + lastObject.btnTrailingConstraintValue
        }
//        let trailingConstraint = NSLayoutConstraint
        button.btnTrailingConstraintValue = constraintOffset
        let trailinLeading = NSLayoutConstraint.constraints(withVisualFormat: "H:[item1]-(\(constraintOffset))-|",
                                                            options: [], metrics: nil,
                                                            views: ["item1" : button])
        
        
        addConstraints(trailinLeading + [centerYconstraint])
    }
    
    func addButtons(withImageNames imageNames: [String]) {
        for name in imageNames {
            addButton(withImageName: name)
        }
    }
    
    func addButton(withTitle title: String, font: UIFont) {
        
    }
    
    @objc func buttonAction(withSender sender: Any?) {

        guard let button = sender as? CustomNavBarButton else {
            return
        }
        actionDelegate?.buttonGotPressed(withCustomButton: button)
    }
    
}
