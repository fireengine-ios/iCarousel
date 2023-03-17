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
        
        /// picked image
        containerView.addSubview(selectedImageContainer)
        selectedImageContainer.translatesAutoresizingMaskIntoConstraints = false
        selectedImageContainer.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        selectedImageContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        selectedImageContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        selectedImageContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        
        selectedImageContainer.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: selectedImageContainer.topAnchor, constant: 2).isActive = true
        imageView.bottomAnchor.constraint(equalTo: selectedImageContainer.bottomAnchor, constant: -2).isActive = true
        imageView.trailingAnchor.constraint(equalTo: selectedImageContainer.trailingAnchor, constant: -2).isActive = true
        imageView.leadingAnchor.constraint(equalTo: selectedImageContainer.leadingAnchor, constant: 2).isActive = true
        
        /// picked label
        containerView.addSubview(pickedView)
        pickedView.translatesAutoresizingMaskIntoConstraints = false
        pickedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 15).isActive = true
        pickedView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        pickedView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        pickedView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        pickedView.addSubview(pickedLabel)
        pickedLabel.translatesAutoresizingMaskIntoConstraints = false
        pickedLabel.topAnchor.constraint(equalTo: pickedView.topAnchor).isActive = true
        pickedLabel.bottomAnchor.constraint(equalTo: pickedView.bottomAnchor).isActive = true
        pickedLabel.trailingAnchor.constraint(equalTo: pickedView.trailingAnchor).isActive = true
        pickedLabel.leadingAnchor.constraint(equalTo: pickedView.leadingAnchor).isActive = true
        
        /// rate label
        containerView.addSubview(rateView)
        rateView.translatesAutoresizingMaskIntoConstraints = false
        rateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 16).isActive = true
        rateView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        rateView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        rateView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        rateView.addSubview(rateLabel)
        rateLabel.translatesAutoresizingMaskIntoConstraints = false
        rateLabel.topAnchor.constraint(equalTo: rateView.topAnchor).isActive = true
        rateLabel.bottomAnchor.constraint(equalTo: rateView.bottomAnchor).isActive = true
        rateLabel.trailingAnchor.constraint(equalTo: rateView.trailingAnchor).isActive = true
        rateLabel.leadingAnchor.constraint(equalTo: rateView.leadingAnchor).isActive = true
        
        setOverAllDesign()
    }
    
    private func setOverAllDesign() {
        pickedLabel.layer.cornerRadius = 6.7
        pickedView.layer.cornerRadius = 6.7
        
        rateView.layer.cornerRadius = 6.7
        rateLabel.layer.cornerRadius = 6.7
        
        selectedImageContainer.layer.cornerRadius = 15.2
        imageView.layer.cornerRadius = 15.2
        
        addGradient(to: pickedView)
        addGradient(to: rateView)
        addGradient(to: selectedImageContainer)
    }
    
    func addGradient(to view: UIView) {
        let gradient: CAGradientLayer = CAGradientLayer()
    
        let colorTop =  AppColor.premiumSecondGradient.cgColor
        let colorBottom = AppColor.InstaPickGradientOne.cgColor
           
        gradient.colors = [colorTop, colorBottom]
        gradient.frame = view.bounds
        gradient.shouldRasterize = true
        view.layer.insertSublayer(gradient, at: 0)
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
