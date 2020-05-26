//
//  ContactSyncSmallCardView.swift
//  Depo
//
//  Created by Konstantin Studilin on 22.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit


enum ContactSyncSmallCardType {
    case showBackup
    case deleteDuplicates
}


final class ContactSyncSmallCardView: UIView, NibInit {
    
    @IBOutlet private weak var icon: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
        }
    }
    @IBOutlet private weak var message: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaMedFont(size: 16.0)
            newValue.textColor = ColorConstants.charcoalGrey
            newValue.numberOfLines = 0
            newValue.textAlignment = .left
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var dividerView: UIView! {
        willSet {
            newValue.translatesAutoresizingMaskIntoConstraints = false
            newValue.backgroundColor = ColorConstants.lighterGray
        }
    }
    
    @IBOutlet private weak var actionButton: UIButton! {
        willSet {
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 14.0)
            newValue.setTitleColor(.lrTealishTwo, for: .normal)
        }
    }

    
    private var actionHandler: VoidHandler?
    
    
    //MARK:- Override
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setupShadow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setupShadow()
    }
    
    
    //MARK:- Public
    
    func setup(with type: ContactSyncSmallCardType, action: VoidHandler?) {
        actionHandler = action
        
        switch type {
            case .showBackup:
                icon.image = UIImage(named: "contact_sync_stage_2_card_backup")
                message.text = TextConstants.contactSyncSmallCardShowBackupMessage
                actionButton.setTitle(TextConstants.contactSyncSmallCardShowBackupButton, for: .normal)
            
            case .deleteDuplicates:
                icon.image = UIImage(named: "contact_sync_stage_2_card_duplicates")
                message.text = TextConstants.contactSyncSmallCardDeleteDuplicatesMessage
                actionButton.setTitle(TextConstants.contactSyncSmallCardDeleteDuplicatesButton, for: .normal)
        }
    }
    
   
    //MARK:- Private
    
    private func setupShadow() {
        layer.cornerRadius = NumericConstants.contactSyncSmallCardCornerRadius
        
        clipsToBounds = false
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = NumericConstants.contactSyncSmallCardShadowOpacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = NumericConstants.contactSyncSmallCardShadowRadius
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: 0,
                                                     width: layer.frame.size.width,
                                                     height: layer.frame.size.height)).cgPath
    }
    
    
    //MARK: - IB Actions
    
    @IBAction private func handleAction(_ sender: Any) {
        actionHandler?()
    }
    
}
