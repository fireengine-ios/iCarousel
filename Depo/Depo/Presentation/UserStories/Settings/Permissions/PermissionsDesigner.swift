//
//  PermissionsDesigner.swift
//  Depo
//
//  Created by Darya Kuliashova on 6/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class PermissionsDesigner: NSObject {
    
    @IBOutlet weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 16)
            newValue.backgroundColor = AppColor.secondaryBackground.color
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var descriptionView: UITextView! {
        willSet {
            newValue.backgroundColor = AppColor.secondaryBackground.color
            newValue.isOpaque = true
            
            newValue.linkTextAttributes = [
                .foregroundColor: AppColor.label.color,
                .underlineColor: UIColor.lrTealishTwo,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            
            /// to remove insets
            /// https://stackoverflow.com/a/42333832/5893286
            newValue.textContainer.lineFragmentPadding = 0
            newValue.textContainerInset = .zero
            
            newValue.isEditable = false
        }
    }
    
    @IBOutlet private weak var informativeLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.informativeDescription
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 8)
            newValue.backgroundColor = AppColor.secondaryBackground.color
            newValue.isOpaque = true
        }
    }
}
