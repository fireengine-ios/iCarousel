//
//  MobilePaymentPermissionView.swift
//  Depo
//
//  Created by YAGIZHAN AKDUMAN on 24.02.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class MobilePaymentPermissionView: UIView, NibInit {
    
    //MARK: IBOutlets
    @IBOutlet private weak var mainStackView: UIStackView! {
        willSet {
            newValue.spacing = 14
            newValue.alignment = .fill
            newValue.axis = .vertical
            newValue.distribution = .fill
            newValue.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            newValue.isLayoutMarginsRelativeArrangement = true
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.marineTwo
            newValue.textAlignment = .center
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 20)
            newValue.text = TextConstants.mobilePaymentViewTitleLabel
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.darkBorder
            newValue.textAlignment = .center
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 16)
            newValue.text = TextConstants.mobilePaymentViewDescriptionLabel
        }
    }
    
    @IBOutlet private weak var approvalFieldStackView: UIStackView! {
        willSet {
            newValue.spacing = 16
            newValue.alignment = .fill
            newValue.axis = .horizontal
            newValue.distribution = .fillProportionally
            newValue.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            newValue.isLayoutMarginsRelativeArrangement = true
        }
    }
    
    @IBOutlet private weak var approveCheckbox: UIButton! {
        willSet {
            let normalImage = UIImage(named: "checkBoxNotSelected")
            newValue.setImage(normalImage, for: .normal)
            let selectedImage = UIImage(named: "checkbox_active")
            newValue.setImage(selectedImage, for: .selected)
        }
    }
    
    @IBOutlet private weak var linkLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.linkBlack
            newValue.textAlignment = .center
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 16)
            newValue.attributedText = NSAttributedString(string: TextConstants.mobilePaymentViewLinkLabel, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.linkTapped))
            newValue.isUserInteractionEnabled = true
            newValue.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet private weak var approveStackView: UIStackView! {
        willSet {
            newValue.layoutMargins = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
            newValue.isLayoutMarginsRelativeArrangement = true
        }
    }
    
    @IBOutlet private weak var approveButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.approve, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = ColorConstants.marineTwo
            newValue.isOpaque = true
            newValue.isEnabled = false
            newValue.alpha = 0.5
        }
    }
    
    // MARK: - Properties
    weak var controller: MobilePaymentPermissionViewInput?
    
}

// MARK: Actions
extension MobilePaymentPermissionView {
    
    // MARK: Checkbox Tap Action
    @IBAction private func checkAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        approveButton.isEnabled = sender.isSelected
        approveButton.alpha = sender.isSelected ? 1.0 : 0.5
    }
    
    // MARK: Approve Button Tap Action
    @IBAction private func approveAction(_ sender: Any) {
        approveCheckbox.isSelected ? controller?.approveTapped() : ()
    }
    
    // MARK: Link Label Tap Gesture
    @objc private func linkTapped() {
        controller?.linkTapped()
    }
    
}
