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
        radioButton.setBackgroundColor(.clear, for: .normal)
        radioButton.setImage(Image.forgetPassUnSelectedRadio.image, for: .normal)
        radioButton.setImage(Image.forgetPassSelectedRadio.image, for: .selected)

        // selection is handled by tableView
        radioButton.isUserInteractionEnabled = false
    }

    func setupLabels() {
        methodNameLabel.textColor = AppColor.forgetPassText.color
        methodNameLabel.font = .appFont(.medium, size: 14)

        contentLabel.textColor = AppColor.forgetPassText.color
        contentLabel.font = .appFont(.regular, size: 12)
    }
}
