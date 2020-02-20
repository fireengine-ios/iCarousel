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
            newValue.textColor = UIColor.lrBrownishGrey
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
    
    @IBOutlet weak var descriptionView: UITextView! {
        willSet {
            newValue.backgroundColor = .white
            newValue.isOpaque = true
            
            newValue.linkTextAttributes = [
                NSAttributedStringKey.foregroundColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineColor.rawValue: UIColor.lrTealishTwo,
                NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
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
            newValue.textColor = UIColor.lrLightBrownishGrey
            newValue.font = .TurkcellSaturaFont(size: 14)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
}


