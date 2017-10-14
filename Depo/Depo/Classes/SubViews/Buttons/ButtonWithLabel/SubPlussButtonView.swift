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
    
    var actionDelegate: SubPlussButtonViewDelegate?
    
    var endCenterXconstant: CGFloat = 0
    var endBotConstant: CGFloat = 0
    
    var botConstraint: NSLayoutConstraint?
    var centerXConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var adjustedLabel: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    class func getFromNib(asLeft: Bool, withImageName imageName: String, labelText: String) -> SubPlussButtonView? {
        guard let subPlassView = Bundle.main.loadNibNamed(SubPlussButtonView.nibName, owner: self, options: nil)?.first as? SubPlussButtonView else {
            return nil
        }
        subPlassView.button.setImage(UIImage(named: imageName), for: .normal)
        subPlassView.setupLabel(withText: labelText)
        subPlassView.translatesAutoresizingMaskIntoConstraints = false
        if asLeft {
            subPlassView.setupConstraints(firstView: subPlassView.adjustedLabel, secondView: subPlassView.button)
        } else {
            subPlassView.setupConstraints(firstView: subPlassView.button, secondView: subPlassView.adjustedLabel)
        }
       
        return subPlassView
    }
    
    func setupConstraints(firstView first: UIView, secondView second: UIView) {

        let winSize = UIScreen.main.bounds
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: winSize.width * 0.33))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 65))
        //TODO: add flexible lable size
        let midTrailinLeading = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[item1]-(2.5)-[mid]-(2.5)-[item2]-(>=0)-|",
                                                               options: [], metrics: nil,
                                                               views: ["item1" : first, "item2" : second, "mid" : middleView])
        
        self.addConstraints( midTrailinLeading)
    }
    
    func setupLabel(withText text: String) {
        self.adjustedLabel.text = text
        self.adjustedLabel.textColor = ColorConstants.blueColor
    }
    
    func changeVisability(toHidden hidden: Bool) {
        button.isEnabled = !hidden
        alpha = hidden ? 0 : 1
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        actionDelegate?.buttonGotPressed(button: self)
    }
    
    func changeConstraints(asHidden hidden: Bool) {
        let oldConstrainValueBot = botConstraint?.constant
        let oldConstrainValueCenterX = centerXConstraint?.constant
        botConstraint?.constant = endBotConstant
        centerXConstraint?.constant = endCenterXconstant
        endBotConstant = oldConstrainValueBot!
        endCenterXconstant = oldConstrainValueCenterX!
    }
    
}
