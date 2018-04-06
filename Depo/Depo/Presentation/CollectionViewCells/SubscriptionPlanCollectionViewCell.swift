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
    
    @IBOutlet weak fileprivate var checkmarkImageView: UIImageView!
    @IBOutlet weak fileprivate var planeNameLabel: UILabel!
    @IBOutlet weak fileprivate var photosCountLabel: UILabel!
    @IBOutlet weak fileprivate var videosCountLabel: UILabel!
    @IBOutlet weak fileprivate var songsCountLabel: UILabel!
    @IBOutlet weak fileprivate var docsCountLabel: UILabel!
    @IBOutlet weak fileprivate var priceLabel: UILabel!
    @IBOutlet weak fileprivate var renewalDateLabel: UILabel!
    @IBOutlet weak fileprivate var storeLabel: UILabel!
    @IBOutlet weak fileprivate var freeButton: UIButton!
    @IBOutlet weak fileprivate var upgradeButton: UIButton!
    @IBOutlet weak fileprivate var cancelButton: UIButton!
    @IBOutlet weak fileprivate var priceHeightConstraint: NSLayoutConstraint!
    
    let borderWidth: CGFloat = 2
    let cornerRadius: CGFloat = 5
    
    weak var delegate: SubscriptionPlanCellDelegate?
    var indexPath = IndexPath()
    
    static func heightForAccount(type: AccountType) -> CGFloat {
        if type == .all {
            return 255
        } else {
            return 220
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        
        cancelButton.titleLabel?.lineBreakMode = .byWordWrapping
        
        freeButton.layer.borderWidth = borderWidth
        freeButton.layer.borderColor = UIColor.lrTealishTwo.cgColor
        freeButton.isUserInteractionEnabled = false

        checkmarkImageView.tintColor = ColorConstants.blueColor
        
        renewalDateLabel.text = ""
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
        checkmarkImageView.isHidden = true
        
        switch plan.type {
        case .default:
            layer.borderColor = ColorConstants.lightPeach.cgColor
            upgradeButton.isHidden = false
        case .free:
            layer.borderColor = ColorConstants.darcBlueColor.cgColor
            freeButton.isHidden = false
            checkmarkImageView.isHidden = false
        case .current:
            layer.borderColor = ColorConstants.darcBlueColor.cgColor
            cancelButton.isHidden = false
            checkmarkImageView.isHidden = false
        }
        
        planeNameLabel.text = plan.name
        photosCountLabel.text = String(format: TextConstants.usageInfoPhotos, plan.photosCount)
        videosCountLabel.text = String(format: TextConstants.usageInfoVideos, plan.videosCount)
        songsCountLabel.text = String(format: TextConstants.usageInfoSongs, plan.songsCount)
        docsCountLabel.text = String(format: TextConstants.usageInfoDocs, plan.docsCount)
        priceLabel.text = plan.priceString
        
        if accountType == .all {
            if let model = plan.model as? SubscriptionPlanBaseResponse, let renewalDate = model.nextRenewalDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM yy"
                renewalDateLabel.text = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(renewalDate.intValue)))
                
                if let type = model.type {
                    storeLabel.text = type.description
                }
            }
            priceHeightConstraint.constant = 18
        } else {
            renewalDateLabel.isHidden = true
            storeLabel.isHidden = true
            priceHeightConstraint.constant = 30
        }
    }
    
    // MARK: - IBActions
    
    @IBAction fileprivate func actionUpgradeButtonClicked(_ sender: UIButton) {
        delegate?.didPressSubscriptionPlanButton(at: indexPath)
    }
    
    @IBAction fileprivate func actionCancelButtonClicked(_ sender: UIButton) {
        delegate?.didPressSubscriptionPlanButton(at: indexPath)
    }
}
