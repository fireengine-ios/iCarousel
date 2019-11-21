//
//  SubPlussButtonView.swift
//  Depo
//
//  Created by Aleksandr on 6/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol SubPlussButtonViewDelegate: class {
    func buttonGotPressed(button: SubPlussButtonView)
}

class SubPlussButtonView: UIView {
    
    static let nibName = "SubPlusButtons"
    
    weak var actionDelegate: SubPlussButtonViewDelegate?
    
    var bottomConstraintOriginalConstant: CGFloat = 0
    var centerXConstraintOriginalConstant: CGFloat = 0
    
    var bottomConstraint: NSLayoutConstraint?
    var centerXConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var adjustedLabel: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    class func getFromNib(asLeft: Bool, withImageName imageName: String, labelText: String) -> SubPlussButtonView? {
        guard let subPlassView = Bundle.main.loadNibNamed(SubPlussButtonView.nibName, owner: nil, options: nil)?.first as? SubPlussButtonView else {
            return nil
        }
        subPlassView.button.setImage(UIImage(named: imageName), for: .normal)
        subPlassView.setupLabel(withText: labelText)
       
        return subPlassView
    }
    
    func setupLabel(withText text: String) {
        self.adjustedLabel.text = text
        self.adjustedLabel.textColor = ColorConstants.grayTabBarButtonsColor
        
        button.accessibilityLabel = text
        button.accessibilityTraits = UIAccessibilityTraitButton
    }
    
    func changeVisability(toHidden hidden: Bool) {
        button.isEnabled = !hidden
        alpha = hidden ? 0 : 1
        if hidden {
            bottomConstraint?.constant = bottomConstraintOriginalConstant
            centerXConstraint?.constant = centerXConstraintOriginalConstant
        }
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        actionDelegate?.buttonGotPressed(button: self)
    }
    
}
