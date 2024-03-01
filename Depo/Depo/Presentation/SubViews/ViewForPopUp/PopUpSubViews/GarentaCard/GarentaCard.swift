//
//  GarentaCard.swift
//  Depo
//
//  Created by Ozan Salman on 29.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

final class GarentaCard: BaseCardView {
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.numberOfLines = 0
            newValue.textAlignment = .left
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet private weak var imageView: LoadingImageView! {
        willSet {
            newValue.contentMode = .scaleToFill
            newValue.isUserInteractionEnabled = true
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            newValue.addGestureRecognizer(tapImage)
        }
    }
    
    private var details: String = ""
    private var pageTitle: String = ""
    private lazy var router = RouterVC()
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        setupCard()
    }
    
    private func setupCard() {
        if let url = cardObject?.details?["imageUrl"].url {
            imageView.loadImageData(with: url)
        }
        
        if let title = cardObject?.content?["title"].string {
            pageTitle = title
            titleLabel.text = title
        }
        
        if let message = cardObject?.content?["message"].string {
            messageLabel.text = message
        }
        
        if let detailsText = cardObject?.content?["detailsText"].string {
            details = detailsText
        }
    }
    
    @objc private func imageTapped() {
        let vc = router.garenta(details: details, pageTitle: pageTitle)
        router.pushViewController(viewController: vc, animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace: CGFloat = 16.0
        let h = messageLabel.frame.origin.y + messageLabel.frame.height + bottomSpace
        if calculatedH != h {
            calculatedH = h
            layoutIfNeeded()
        }
    }
}
