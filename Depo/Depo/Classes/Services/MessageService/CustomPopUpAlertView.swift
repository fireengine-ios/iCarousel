//
//  CustomPopUpAlert.swift
//  Depo
//
//  Created by Aleksandr on 6/19/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol CustomPopUpAlertDelegate {
    func firstButtonPressed()
    func secondButtonPressed()
}

class CustomPopUpAlert: UIView {
    
    enum CustomPopUpAlertType {
        case info
        case regular
    }
    
    static let nibName = "CustomPopUpAlert"
    
    @IBOutlet weak var infoImageView: UIImageView!
    
    @IBOutlet weak var alertTextView: UITextView!
    @IBOutlet weak var alertLabel: UILabel!
    
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var twoButtonsContainer: UIView!
    @IBOutlet weak var horisontalButtonSeparator: UIView!
    @IBOutlet weak var verticalButtonSeparator: UIView!
    
    @IBOutlet weak var infoImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var infoImageTop: NSLayoutConstraint!
    
    @IBOutlet weak var textFieldBotContraint: NSLayoutConstraint!
    let iPhoneHeightReg: CGFloat = 168
    let iPhoneWeightReg: CGFloat = 320
    let iPadHeightReg: CGFloat = 168
    let iPadWeightReg: CGFloat = 168
    let iPhoneWeightInfo: CGFloat = 280
    let iPhoneHeightInfo: CGFloat = 168
    let iPadHeightInfo: CGFloat = 168
    
    let infoImageHeightOriginalconstant: CGFloat = 41
    let infoImageTopOriginalconstant: CGFloat = 35
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    init() {
        super.init(frame: CGRect())
    }
    
    class func loadFromNib() -> CustomPopUpAlert? {
        guard let customAlert = Bundle.main.loadNibNamed(CustomPopUpAlert.nibName, owner: self, options: nil)?.first as? CustomPopUpAlert else {
            return nil
        }
        customAlert.translatesAutoresizingMaskIntoConstraints = false
        
        customAlert.clipsToBounds = true
        customAlert.layer.cornerRadius = 5
        return customAlert
    }
    
    func setup(asType type: CustomPopUpAlertType) {
//        var alertHeight: CGFloat
        switch type {
        case .regular:
            infoImageHeight.constant = 0
            infoImageTop.constant = 0
            addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: iPhoneWeightReg))

        case .info:
            infoImageHeight.constant = infoImageHeightOriginalconstant
            infoImageTop.constant = infoImageTopOriginalconstant
            addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: iPhoneWeightInfo))

        }
        layoutIfNeeded()
    }
    
    private func cofigurate() {
        
    }

}
