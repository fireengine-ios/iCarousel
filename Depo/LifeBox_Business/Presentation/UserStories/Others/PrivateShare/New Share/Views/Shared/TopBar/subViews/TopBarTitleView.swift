//
//  TopBarTitle.swift
//  Depo
//
//  Created by Alex Developer on 03.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

final class TopBarTitleView: UIView, NibInit {
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardMediumFont(size: 24)
            newValue.textColor = ColorConstants.confirmationPopupTitle
            newValue.text = ""
        }
    }
    
//    private var titleText: String?
    
    func setup(text: String) {
        titleLabel.text = text
    }
    
    func setTitleAlpha(alpha: CGFloat) {
        titleLabel.alpha = alpha
    }
    
}
