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
        rateView.heightAnchor.constraint(equalToConstant: isIPad ? 20 : 15).isActive = true
        
        imageViewHeightConstraint.constraintWithMultiplier(0.96).isActive = true
    }
    
    override func setupLabelsDesign(isIPad: Bool) {
        super.setupLabelsDesign(isIPad: isIPad)
        
        rateLabel.font = UIFont.TurkcellSaturaBolFont(size: isIPad ? 14 : 10)
    }
    
    override func getPhotoUrl() -> URL? {
        return model?.getSmallImageURL()
    }
    
    override func isNeedHidePickedView(hasSmallPhotos: Bool) -> Bool {
        return true
    }
}
