//
//  ExternalCard.swift
//  Depo
//
//  Created by Ozan Salman on 26.06.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

final class ExternalCard: BaseCardView {
    
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
    
    private var detailsUrl: String = ""
    private lazy var router = RouterVC()
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        setupCard()
    }
    
    private func setupCard() {
        if let url = cardObject?.details?["imageUrl"].url {
            imageView.loadImageData(with: url)
        }
        
        if let url = cardObject?.details?["detailsUrl"].string {
            detailsUrl = url
        }
    }
    
    @objc private func imageTapped() {
        let url = URL(string: detailsUrl)
        UIApplication.shared.open(url!)
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
