//
//  EmptyDataView.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol EmptyDataViewDelegate: AnyObject {
    func didButtonTapped()
}

final class EmptyDataView: UIView, NibInit {
    weak var delegate: EmptyDataViewDelegate?
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 14)
        }
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!
    
    @IBOutlet private weak var actionButton: UIButton!
    
    func configure(title: String, image: UIImage, actionTitle: String? = nil) {
        messageLabel.text = title
        iconImageView.image = image
        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.isHidden = actionTitle == nil
    }
    
    @IBAction private func onActionButton(_ sender: UIButton) {
        delegate?.didButtonTapped()
    }
}
