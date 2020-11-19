//
//  PrivateShareAccessListHeader.swift
//  Depo
//
//  Created by Andrei Novikau on 11/19/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareAccessListHeader: UIView, NibInit {

    static func with(name: String?, username: String?) -> PrivateShareAccessListHeader {
        let view = PrivateShareAccessListHeader.initFromNib()
        view.nameLabel.text = name
        view.userNameLabel.text = username
        return view
    }
    
    @IBOutlet private weak var nameLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaMedFont(size: 16)
            newValue.textColor = .lrBrownishGrey
        }
    }
    
    @IBOutlet private weak var userNameLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaFont(size: 18)
            newValue.textColor = .black
        }
    }
    
}
