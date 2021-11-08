//
//  VerificationMethodTableViewCell.swift
//  Depo
//
//  Created by Hady on 8/26/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

class VerificationMethodTableViewCell: UITableViewCell {
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var methodNameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
        setupLabels()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        radioButton.isSelected = selected
    }
}

private extension VerificationMethodTableViewCell {
    func setupButton() {
        radioButton.setImage(UIImage(named: "emtyRectangle"), for: .normal)
        radioButton.setImage(UIImage(named: "selectedRectangle"), for: .selected)

        // selection is handled by tableView
        radioButton.isUserInteractionEnabled = false
    }

    func setupLabels() {
        methodNameLabel.textColor = ColorConstants.duplicatesGray
        methodNameLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)

        contentLabel.textColor = ColorConstants.duplicatesGray
        contentLabel.font = UIFont.TurkcellSaturaMedFont(size: 16)
    }
}
