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
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        willSet {
            newValue.textColor = UIColor.lrLightBrownishGrey
            newValue.font = .TurkcellSaturaFont(size: 16)
            newValue.backgroundColor = .white
            newValue.isOpaque = true
        }
    }
}
