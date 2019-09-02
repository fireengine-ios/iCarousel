//
//  SubscriptionPlanCollectionViewCell.swift
//  Depo
//
//  Created by Maksim Rahleev on 12/08/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import UIKit

protocol SubscriptionPlanCellDelegate: class {
    func didPressSubscriptionPlanButton(at indexPath: IndexPath)
}

class SubscriptionPlanCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak fileprivate var planeNameLabel: UILabel!
    @IBOutlet weak fileprivate var photosCountLabel: UILabel!
    @IBOutlet weak fileprivate var videosCountLabel: UILabel!
    @IBOutlet weak fileprivate var songsCountLabel: UILabel!
    @IBOutlet weak fileprivate var docsCountLabel: UILabel!
    @IBOutlet weak fileprivate var priceLabel: UILabel!
    @IBOutlet weak fileprivate var dateInfoLabel: UILabel!
    @IBOutlet weak fileprivate var storeLabel: UILabel!
    @IBOutlet weak fileprivate var freeButton: UIButton!
    @IBOutlet weak fileprivate var upgradeButton: UIButton!
    @IBOutlet weak fileprivate var cancelButton: UIButton!
    @IBOutlet weak fileprivate var priceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var stackView: UIStackView!
    
    let borderWidth: CGFloat = 2
    let cornerRadius: CGFloat = 5
    
    weak var delegate: SubscriptionPlanCellDelegate?
    var indexPath = IndexPath()
    
    func heightForAccount() -> CGFloat {
        return stackView.frame.maxY + 8
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = UIColor.lrTealish.cgColor
        
        cancelButton.titleLabel?.lineBreakMode = .byWordWrapping
        cancelButton.titleLabel?.textAlignment = .center
        cancelButton.titleLabel?.numberOfLines = 2
        let title = NSAttributedString(string: TextConstants.cancelButtonTitle, attributes: [.font : UIFont.TurkcellSaturaDemFont(size: 14),
                                                                                             .foregroundColor : ColorConstants.darkBlueColor,
                                                                                             .underlineStyle : 1])
        cancelButton.setAttributedTitle(title, for: .normal)

        upgradeButton.setTitle(TextConstants.upgrade, for: .normal)
        
        freeButton.setTitle(TextConstants.free, for: .normal)
        freeButton.layer.borderWidth = borderWidth
        freeButton.layer.borderColor = UIColor.lrTealishTwo.cgColor
        freeButton.isUserInteractionEnabled = false
        
        dateInfoLabel.text = ""
        storeLabel.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        freeButton.layer.cornerRadius = freeButton.bounds.height / 2
    }
    
    func configure(with plan: SubscriptionPlan, accountType: AccountType) {
        freeButton.isHidden = true
        upgradeButton.isHidden = true
        cancelButton.isHidden = true
        storeLabel.isHidden = true
        
        switch plan.type {
        case .default:
            upgradeButton.isHidden = false
        case .free:
            priceLabel.isHidden = true
            freeButton.isHidden = false
        case .current:
            cancelButton.isHidden = false
        }
        
        
        planeNameLabel.text = String(format: TextConstants.availableHeadNameTitle, plan.name)
        priceLabel.text = plan.priceString
        
        photosCountLabel.text = String(format: TextConstants.usageInfoPhotos, plan.photosCount)
        videosCountLabel.text = String(format: TextConstants.usageInfoVideos, plan.videosCount)
        songsCountLabel.text = String(format: TextConstants.usageInfoSongs, plan.songsCount)
        docsCountLabel.text = String(format: TextConstants.usageInfoDocs, plan.docsCount)
        
        if let model = plan.model as? SubscriptionPlanBaseResponse {
            
            if let storageSize = model.subscriptionPlanQuota?.bytesString {
                planeNameLabel.text = storageSize
            }

            if let renewalDate = model.nextRenewalDate {
                let date = dateString(from: renewalDate)
                dateInfoLabel.text = String(format: TextConstants.renewalDate, date)
            }
        }
        priceHeightConstraint.constant = 18
    }
    
    // MARK: - IBActions
    
    @IBAction fileprivate func actionUpgradeButtonClicked(_ sender: UIButton) {
        delegate?.didPressSubscriptionPlanButton(at: indexPath)
    }
    
    @IBAction fileprivate func actionCancelButtonClicked(_ sender: UIButton) {
        delegate?.didPressSubscriptionPlanButton(at: indexPath)
    }
    
    // MARK: - Date Helper
    
    private func dateString(from dateInterval: NSNumber) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(dateInterval.doubleValue/1000)))
    }
}
