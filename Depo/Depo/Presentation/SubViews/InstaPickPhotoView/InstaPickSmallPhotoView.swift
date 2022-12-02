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
        
        containerView.addSubview(selectedImageContainer)
        selectedImageContainer.translatesAutoresizingMaskIntoConstraints = false
        selectedImageContainer.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        selectedImageContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        selectedImageContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        selectedImageContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        
        selectedImageContainer.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: selectedImageContainer.topAnchor, constant: 0.5).isActive = true
        imageView.bottomAnchor.constraint(equalTo: selectedImageContainer.bottomAnchor, constant: -0.5).isActive = true
        imageView.trailingAnchor.constraint(equalTo: selectedImageContainer.trailingAnchor, constant: -0.5).isActive = true
        imageView.leadingAnchor.constraint(equalTo: selectedImageContainer.leadingAnchor, constant: 0.5).isActive = true
        
        /// rate label
        containerView.addSubview(rateView)
        rateView.translatesAutoresizingMaskIntoConstraints = false
        rateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 7).isActive = true
        rateView.heightAnchor.constraint(equalToConstant: 14).isActive = true
        rateView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        rateView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 7).isActive = true
        
        rateView.addSubview(rateLabel)
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        rateLabel.topAnchor.constraint(equalTo: rateView.topAnchor).isActive = true
        rateLabel.bottomAnchor.constraint(equalTo: rateView.bottomAnchor).isActive = true
        rateLabel.trailingAnchor.constraint(equalTo: rateView.trailingAnchor).isActive = true
        rateLabel.leadingAnchor.constraint(equalTo: rateView.leadingAnchor).isActive = true
        
        setOverAllDesign()
    }
    
    private func setOverAllDesign() {
        rateView.layer.cornerRadius = 2.3
        rateLabel.layer.cornerRadius = 2.3
        
        selectedImageContainer.layer.cornerRadius = 3.8
        imageView.layer.cornerRadius = 3.8
        
        rateView.backgroundColor = AppColor.button.color
        selectedImageContainer.backgroundColor = AppColor.button.color
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
