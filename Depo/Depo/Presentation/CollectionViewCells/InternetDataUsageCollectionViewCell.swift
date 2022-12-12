//
//  MyDataUsageCollectionViewCell.swift
//  Depo
//
//  Created by Raman Harhun on 3/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

class InternetDataUsageCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets
    @IBOutlet weak var progressView: RoundedProgressView! {
        didSet {
            progressView.progressTintColor = AppColor.tint.color
            progressView.trackTintColor = AppColor.tint.color.withAlphaComponent(0.25)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = ""
            nameLabel.numberOfLines = 0
            nameLabel.font = .appFont(.medium, size: 12)
            nameLabel.textColor = AppColor.tint.color
        }
    }
    
    @IBOutlet weak var usageDetailLabel: UILabel! {
        didSet {
            usageDetailLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var usedPercentageLabel: UILabel! {
        didSet {
            usedPercentageLabel.text = ""
            usedPercentageLabel.numberOfLines = 0
            usedPercentageLabel.font = .appFont(.regular, size: 12)
            usedPercentageLabel.textColor = AppColor.tint.color
        }
    }
    
    @IBOutlet weak var renewDateLabel: UILabel! {
        didSet {
            renewDateLabel.text = ""
            renewDateLabel.numberOfLines = 0
            renewDateLabel.font = .appFont(.medium, size: 12)
            renewDateLabel.textColor = AppColor.tint.color
        }
    }
    
    
    //MARK: Utility Methods
    func configureWith(model: InternetDataUsage, indexPath: IndexPath) {
        if let dateString = model.expiryDate?.getDateInFormat(format: "dd MMM YYYY") {
            renewDateLabel.text = String(format: TextConstants.renewDate, dateString)
        }
        
        let usedVolume: CGFloat
        if let remaining = model.remaining, let total = model.total {
            usedVolume = CGFloat((1 - (remaining / total)) * 100)
        } else {
            usedVolume = 0
        }
        
        progressView.progress = Float(usedVolume / 100)
        
        usedPercentageLabel.text =  String(format: TextConstants.usagePercentage, usedVolume.rounded(.toNearestOrAwayFromZero))
        
        nameLabel.text = model.offerName
        
        ///in some cells this label collapsed, lines below fix this
        let textHeight: CGFloat = 25
        let maxNameLabelWidth = self.frame.width - String(format: TextConstants.usagePercentage, usedVolume)
            .width(for: textHeight, font: UIFont.appFont(.medium, size: 12))
        nameLabel.preferredMaxLayoutWidth = maxNameLabelWidth
        
        let usageInfo = String(format: TextConstants.packageSpaceDetails,
                               model.usedString,
                               model.totalString)
        
        ///In design(https://zpl.io/aNPYeWk) volume values are bold but we don't have well done logic for both (RTL and LTR) languages
        let attributedString = NSAttributedString(string: usageInfo,
                                                  attributes: [
                                                    .font               : UIFont.appFont(.medium, size: 12),
                                                    .foregroundColor    : UIColor(white: 84.0 / 255.0, alpha: 1.0),
                                                    .kern               : 0.0
                                                  ])
        
        usageDetailLabel.attributedText = attributedString
    }
}
