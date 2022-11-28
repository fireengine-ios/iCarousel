//
//  InstaPickSmallPhotoView.swift
//  Depo
//
//  Created by Raman Harhun on 1/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickSmallPhotoView: InstaPickPhotoView {

    override func setupLayout(isIPad: Bool) {
        super.setupLayout(isIPad: isIPad)
        
        //relation constraints
        rateViewCenterYConstraint.constraintWithMultiplier(1.8).isActive = true
        
        //size constraints
        rateView.heightAnchor.constraint(equalToConstant: isIPad ? 19 : 14).isActive = true
        
        imageViewHeightConstraint.constraintWithMultiplier(0.96).isActive = true
    }
    
    override func configurePictureNotFound(fontSize: CGFloat, imageWidth: CGFloat, spacing: CGFloat) {
        super.configurePictureNotFound(fontSize: 6, imageWidth: 10, spacing: 4)
    }
    
    override func setupLabelsDesign(isIPad: Bool) {
        super.setupLabelsDesign(isIPad: isIPad)
        
        rateLabel.font = .appFont(.regular, size: isIPad ? 13 : 7)
    }
    
    override func getPhotoUrl() -> URL? {
        return model?.getSmallImageURL()
    }
    
    override func isNeedHidePickedView(hasSmallPhotos: Bool) -> Bool {
        return true
    }
}
