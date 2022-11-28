//
//  InstaPickBigPhotoView.swift
//  Depo
//
//  Created by Raman Harhun on 1/30/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickBigPhotoView: InstaPickPhotoView {

    override func setupLayout(isIPad: Bool) {
        super.setupLayout(isIPad: isIPad)
        
        //relation constraints
        rateViewCenterYConstraint.constraintWithMultiplier(1.5).isActive = true
        pickedViewCenterXConstraint.constraintWithMultiplier(0.5).isActive = true

        //size constraints
        rateView.heightAnchor.constraint(equalToConstant: isIPad ? 42 : 32).isActive = true
        pickedView.widthAnchor.constraint(equalToConstant: isIPad ? 110 : 80).isActive = true
        pickedView.heightAnchor.constraint(equalToConstant: isIPad ? 40 : 30).isActive = true
        
        imageViewHeightConstraint.constraintWithMultiplier(0.97).isActive = true
    }
    
    override func configurePictureNotFound(fontSize: CGFloat, imageWidth: CGFloat, spacing: CGFloat) {
        super.configurePictureNotFound(fontSize: 16, imageWidth: 30, spacing: 8)
    }
    
    override func setupLabelsDesign(isIPad: Bool) {
        super.setupLabelsDesign(isIPad: isIPad)

        rateLabel.font = .appFont(.regular, size: isIPad ? 18 : 12)
    }
    
    override func getPhotoUrl() -> URL? {
        return model?.getLargeImageURL()
    }
    
    override func isNeedHidePickedView(hasSmallPhotos: Bool) -> Bool {
        return !hasSmallPhotos
    }
}
