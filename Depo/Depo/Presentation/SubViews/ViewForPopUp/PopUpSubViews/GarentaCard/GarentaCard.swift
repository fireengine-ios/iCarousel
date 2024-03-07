//
//  GarentaCard.swift
//  Depo
//
//  Created by Ozan Salman on 29.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

final class GarentaCard: BaseCardView {
    
    @IBOutlet private weak var imageView: LoadingImageView! {
        willSet {
            newValue.contentMode = .scaleToFill
            newValue.isUserInteractionEnabled = true
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            newValue.addGestureRecognizer(tapImage)
        }
    }
    
    @IBOutlet weak var cancelImageView: UIImageView! {
        willSet {
            newValue.image = Image.iconCancelBorder.image
            newValue.isUserInteractionEnabled = true
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(cancelImageTapped))
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
        }
        
        if let detailsText = cardObject?.content?["detailsText"].string {
            details = detailsText
        }
    }
    
    @objc private func imageTapped() {
        let vc = router.garenta(details: details, pageTitle: pageTitle)
        router.pushViewController(viewController: vc, animated: false)
    }
    
    @objc private func cancelImageTapped() {
        deleteCard()
    }
    
    override func deleteCard() {
        super.deleteCard()
        CardsManager.default.stopOperationWith(type: .garenta)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = imageView.frame.size.height
        if calculatedH != height {
            calculatedH = height
            layoutIfNeeded()
        }
    }
}
