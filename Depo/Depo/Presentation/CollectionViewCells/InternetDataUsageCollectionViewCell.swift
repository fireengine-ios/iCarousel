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
            progressView.progressTintColor = UIColor.lrTealish
            progressView.backgroundColor = UIColor.lrTealish.withAlphaComponent(0.25)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = ""
            nameLabel.numberOfLines = 0
            nameLabel.font = UIFont.TurkcellSaturaMedFont(size: 18)
            nameLabel.textColor = UIColor.lrTealish
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
            usedPercentageLabel.font = UIFont.TurkcellSaturaDemFont(size: 16)
            usedPercentageLabel.textColor = UIColor.lrTealish
        }
    }
    
    @IBOutlet weak var renewDateLabel: UILabel! {
        didSet {
            renewDateLabel.text = ""
            renewDateLabel.numberOfLines = 0
            renewDateLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
            renewDateLabel.textColor = ColorConstants.textGrayColor
        }
    }
    
    
    //MARK: Utility Methods
    func configureWith(model: InternetDataUsage, indexPath: IndexPath) {
        if let dateString = model.expiryDate?.getDateInFormat(format: "dd MMM YYYY") {
            renewDateLabel.text = String(format: TextConstants.renewDate, dateString)
        }
        
        let usedVolume = (((model.remaining ?? 0) / (model.total ?? 0)) * 100).rounded(.toNearestOrAwayFromZero)
        usedPercentageLabel.text =  String(format: TextConstants.usagePercentage, usedVolume)
        
        nameLabel.text = model.offerName
        ///in some cells this label collapsed, lines below fix this
        let maxNameLabelWidth = self.frame.width - String(format: TextConstants.usagePercentage, usedVolume)
            .width(for: 25, font: UIFont.TurkcellSaturaDemFont(size: 16))
        nameLabel.preferredMaxLayoutWidth = maxNameLabelWidth
        
        let usageInfo = String(format: TextConstants.packageSpaceDetails,
                               model.usedString,
                               model.totalString)
        
        ///In design(https://zpl.io/aNPYeWk) BG values are bold but we don't have well done logic for both (RTL and LTR) languages
        let attributedString = NSAttributedString(string: usageInfo,
                                                  attributes: [
            .font               : UIFont.TurkcellSaturaRegFont(size: 18),
            .foregroundColor    : UIColor(white: 84.0 / 255.0, alpha: 1.0),
            .kern               : 0.0
        ])
        
        usageDetailLabel.attributedText = attributedString
    }
}
