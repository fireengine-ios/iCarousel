//
//  ContactSyncSmallCardView.swift
//  Depo
//
//  Created by Konstantin Studilin on 22.05.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit


enum ContactSyncSmallCardType {
    case showBackup(date: Date)
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

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()
    
    private let attributedLastBackupMessage: NSAttributedString = {
        let attributesStatic: [NSAttributedStringKey : Any] = [
            .font: UIFont.TurkcellSaturaMedFont(size: 16.0),
            .foregroundColor: ColorConstants.charcoalGrey
        ]
        let attributedStatic = NSAttributedString(string: TextConstants.contactSyncSmallCardShowBackupMessage, attributes: attributesStatic)
        
        return attributedStatic
    }()
    
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
            case .showBackup(_):
                icon.image = UIImage(named: "contact_sync_stage_2_card_backup")
                message.text = " "
                actionButton.setTitle(TextConstants.contactSyncSmallCardShowBackupButton, for: .normal)
            
            case .deleteDuplicates:
                icon.image = UIImage(named: "contact_sync_stage_2_card_duplicates")
                message.text = TextConstants.contactSyncSmallCardDeleteDuplicatesMessage
                actionButton.setTitle(TextConstants.contactSyncSmallCardDeleteDuplicatesButton, for: .normal)
        }
    }
    
    func update(type: ContactSyncSmallCardType) {
        switch type {
            case .showBackup(let date):
                let attributed = attributedString(dateString: dateFormatter.string(from: date))
                message.attributedText = attributed
                
            default:
                break
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
    
    
    
    
    private func attributedString(dateString: String) -> NSMutableAttributedString{
        let attributesDate: [NSAttributedStringKey : Any] = [
            .font: UIFont.TurkcellSaturaBolFont(size: 16.0),
            .foregroundColor: ColorConstants.charcoalGrey
        ]
        let attributedDate = NSMutableAttributedString(string: dateString + ".", attributes: attributesDate)
        
        attributedDate.insert(attributedLastBackupMessage, at: 0)
        
        return attributedDate
    }
    
    //MARK: - IB Actions
    
    @IBAction private func handleAction(_ sender: Any) {
        actionHandler?()
    }
    
}
