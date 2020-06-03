//
//  ContactDetailNoInfoCell.swift
//  Depo
//
//  Created by Andrei Novikau on 6/2/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class ContactDetailNoInfoCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.contactDetailNoInfo
            newValue.textColor = ColorConstants.grayTabBarButtonsColor
            newValue.font = .TurkcellSaturaMedFont(size: 20)
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.textAlignment = .center
        }
    }
}
