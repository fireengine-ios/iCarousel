//
//  SubjectDetailsDesigner.swift
//  Depo
//
//  Created by Darya Kuliashova on 9/24/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class SubjectDetailsDesigner: NSObject {
    @IBOutlet private weak var mainView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor.black.withAlphaComponent(0.33)
            newValue.isOpaque = false
        }
    }
    
    @IBOutlet private weak var detailsView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 4
        }
    }
    
    @IBOutlet private weak var subjectLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 21)
        }
    }
    
    @IBOutlet private weak var cancelButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "closeIcon"), for: .normal)
            newValue.tintColor = ColorConstants.closeIconButtonColor
        }
    }
}
