//
//  SettingsStorageTableViewCell.swift
//  Depo
//
//  Created by Anton Ignatovich on 12.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class SettingsStorageTableViewCell: UITableViewCell {
    
    private var isProfilePage = false

    @IBOutlet private weak var iconContainerView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.iconBackgroundView.color
            newValue.layer.cornerRadius = 5
        }
    }
    @IBOutlet private weak var innerContainerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!

    @IBOutlet private weak var mainLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 14)
            newValue.textColor = ColorConstants.Text.labelTitle.color
            newValue.text = TextConstants.settingsPageStorageUseHeader
        }
    }

    @IBOutlet private weak var storageFullnessProgressView: LineProgressView! {
        willSet {
            newValue.set(lineBackgroundColor: ColorConstants.separator.color)
            newValue.set(lineColor: ColorConstants.a2FAActiveProgress.color)
            newValue.setContentCompressionResistancePriority(.required, for: .vertical)
            newValue.lineWidth = 6
            newValue.targetValue = 1
            newValue.set(progress: 0)
        }
    }

    @IBOutlet private weak var storageUsageLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 14)
            newValue.textColor = ColorConstants.Text.labelTitle.color
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 5
        selectionStyle = .none
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if isProfilePage {
            innerContainerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 15).activate()
            innerContainerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).activate()
            layoutIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowLayer()
    }

    func setup(with storageUsageInfo: SettingsStorageUsageResponseItem, isProfilePage: Bool = false) {

        if isProfilePage {
            self.isProfilePage = isProfilePage
        }

        storageFullnessProgressView.isHidden = storageUsageInfo.unlimitedStorage ?? true
        mainLabel.isHidden = storageUsageInfo.unlimitedStorage ?? true

        if storageUsageInfo.unlimitedStorage == true {
            storageUsageLabel.attributedText = nil
            storageUsageLabel.text = String(format: TextConstants.settingsPageStorageUsedUnlimited, storageUsageInfo.usage ?? "")
            return
        } else {
            let attributes = [NSAttributedString.Key.foregroundColor: ColorConstants.loginPopupDescription.color,
                              NSAttributedString.Key.font: UIFont.GTAmericaStandardRegularFont(size: 12)]

            let usageText = storageUsageInfo.usage ?? ""
            let targetText = String(format: TextConstants.settingsPageStorageUsedLimited, usageText, storageInBytesToReadableFormat(storageUsageInfo.storageInBytes ?? 0))

            let attributedString = NSMutableAttributedString(string: targetText, attributes: attributes)
            let extensionRange = NSMakeRange(0, usageText.count + 3) // 2 = ' '(1) + '/'(2)
            attributedString.addAttributes([
                NSAttributedString.Key.foregroundColor: ColorConstants.Text.labelTitle,
                NSAttributedString.Key.font: UIFont.GTAmericaStandardMediumFont(size: 12)
            ], range: extensionRange)


            storageUsageLabel.attributedText = attributedString
        }

        let storageInKb = CGFloat(storageUsageInfo.storageInBytes ?? 0) / 1024.0
        let usedStorageInKb = CGFloat(storageUsageInfo.usageInBytes) / 1024.0
        storageFullnessProgressView.targetValue = storageInKb
        storageFullnessProgressView.set(progress: usedStorageInKb)
    }

    private func updateShadowLayer() {
        innerContainerView.layer.masksToBounds = false
        innerContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        innerContainerView.layer.shadowOffset = CGSize.zero
        innerContainerView.layer.shadowRadius = 5
        innerContainerView.layer.shadowOpacity = 0.2
    }

    private func storageInBytesToReadableFormat(_ input: Int64) -> String {
        let inputInKilobytes = Double(input) / 1024.0
        let inputInMegabytes = Double(input) / 1024.0 / 1024.0

        if inputInMegabytes >= 1, inputInMegabytes < 1000 {
            return String(format: "%.2f", inputInMegabytes) + " MB"
        } else if inputInMegabytes >= 1000 {
            let inputInGigabytes = inputInMegabytes / 1024.0
            return String(format: "%.2f", inputInGigabytes) + " GB"
        } else {
            if inputInKilobytes < 1 {
                return "\(input) B"
            } else {
                return String(format: "%.2f", inputInKilobytes) + " Kb"
            }
        }
    }
}
