//
//  ContactSyncScheduleCard.swift
//  Depo
//
//  Created by Konstantin Studilin on 04.06.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

class ContactSyncScheduleCard: UIView, NibInit {
    @IBOutlet private weak var title: UILabel! {
        willSet {
            newValue.text = TextConstants.contactSyncBackupSuccessCardTitle
            newValue.font = .TurkcellSaturaDemFont(size: 18.0)
            newValue.textColor = ColorConstants.navy
            newValue.numberOfLines = 0
            newValue.textAlignment = .left
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet weak var message: UILabel! {
        willSet {
            newValue.text = TextConstants.contactSyncBackupSuccessCardMessage
            newValue.font = .TurkcellSaturaFont(size: 16.0)
            newValue.textColor = .lrBrownishGrey
            newValue.numberOfLines = 0
            newValue.textAlignment = .left
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var syncOptionText: UILabel! {
        willSet {
            newValue.text = TextConstants.contactSyncBigCardAutobackupFormat
            newValue.font = .TurkcellSaturaDemFont(size: 14.0)
            newValue.textColor =  .lrTealishTwo
            newValue.numberOfLines = 1
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var syncOptionButton: UIButton! {
        willSet {
            newValue.setTitle(" ", for: .normal)
            newValue.backgroundColor = .clear
        }
    }
    
    
    private var actionHandler: SenderHandler?
    
    
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
    
    func set(periodicSyncOption: PeriodicContactsSyncOption) {
        DispatchQueue.toMain {
            self.syncOptionText.text = String(format: TextConstants.contactSyncBigCardAutobackupFormat, periodicSyncOption.localizedText)
        }
    }
    
    @discardableResult
    func onAction(handler: @escaping SenderHandler) -> ContactSyncScheduleCard {
        actionHandler = handler
        return self
    }
    
    
    //MARK: - Private
    
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
    
    @IBAction private func didTapSyncOptionButton(_ sender: Any) {
        actionHandler?(sender)
    }
}
