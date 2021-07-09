//
//  InstaPickHashtagCell.swift
//  Depo
//
//  Created by Raman Harhun on 1/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol InstaPickHashtagCellDelegate: AnyObject {
    func dismiss(cell: InstaPickHashtagCell)
}

final class InstaPickHashtagCell: UICollectionViewCell {

    @IBOutlet private weak var shadowView: UIView!
    @IBOutlet private weak var hashtagLabel: UILabel!
    
    private weak var delegate: InstaPickHashtagCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        hashtagLabel.font = UIFont.TurkcellSaturaMedFont(size: 14)
        hashtagLabel.textColor = ColorConstants.darkText
        
        shadowView.layer.cornerRadius = NumericConstants.instaPickHashtagCellCornerRadius
        
        shadowView.layer.borderColor = ColorConstants.darkBorder.withAlphaComponent(NumericConstants.instaPickHashtagCellBorderColorAlpha).cgColor
        shadowView.layer.borderWidth = NumericConstants.instaPickHashtagCellBorderWidth
        
        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(NumericConstants.instaPickHashtagCellShadowColorAlpha).cgColor
        shadowView.layer.shadowOpacity = NumericConstants.packageViewShadowOpacity
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowRadius = NumericConstants.instaPickHashtagCellShadowRadius
    }
    
    func configure(with hashtag: String, delegate: InstaPickHashtagCellDelegate) {
        hashtagLabel.text = hashtag
        self.delegate = delegate
    }

    @IBAction private func onCloseTap(_ sender: Any) {
        delegate?.dismiss(cell: self)
    }
}
