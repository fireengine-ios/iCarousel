//
//  ReferenceCard.swift
//  Depo
//
//  Created by Hady on 14.06.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import SwiftyJSON

final class PhotoPrintCard: BaseCardView {

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.printDiscoverCardTitle)
        }
    }
    
    @IBOutlet private weak var messageLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.light, size: 14)
            newValue.textColor = AppColor.label.color
            newValue.text = localized(.printDiscoverCardBody)
        }
    }
    
    @IBOutlet private weak var imageView: LoadingImageView! {
        willSet {
            newValue.contentMode = .scaleToFill
        }
    }
    
    @IBOutlet private weak var actionButton: UIButton! {
        willSet {
            newValue.setTitle(localized(.printPackageView), for: .normal)
            newValue.setTitleColor(AppColor.settingsButtonColor.color, for: .normal)
            newValue.setTitleColor(AppColor.settingsButtonColor.color, for: .highlighted)
            newValue.titleLabel?.font = .appFont(.bold, size: 14)
        }
    }
    
    @IBOutlet weak var campaignImageView: UIImageView!
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        loadImage()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func loadImage() {
        if let url = cardObject?.details?["thumbnail"].url {
            imageView.loadImageData(with: url)
        }
    }
    
    override func deleteCard() {
        /// we don't need: super.deleteCard()
        CardsManager.default.manuallyDeleteCardsByType(type: .photoPrint, homeCardResponse: cardObject)
        CardsManager.default.stopOperationWith(type: .photoPrint, serverObject: cardObject)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomSpace: CGFloat = 16.0
        let h = actionButton.frame.origin.y + actionButton.frame.height + bottomSpace
        if calculatedH != h {
            calculatedH = h
            layoutIfNeeded()
        }
    }
    
    @IBAction private func onActionButton(_ sender: UIButton) {
        openPackage()
    }
    
    private func openPackage() {
        let router = RouterVC()
        router.pushViewController(viewController: router.myStorage(usageStorage: nil))
    }
}
