//
//  PremiumFeaturesView.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 11/17/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PremiumFeaturesView: UIView {

    private enum Feature {
        case backUp
        case contacts
        case places
        case face
        case object
        case photoPick

        static let allFeatureTypes: [Feature] = [.backUp, .contacts, .places, .face, .object, .photoPick]

        var title: String {
            switch self {
            case .backUp:
                return TextConstants.backUpShort
            case .contacts:
                return TextConstants.removeDuplicateShort
            case .places:
                return TextConstants.placesRecognitionShort
            case .face:
                return TextConstants.faceRecognitionShort
            case .object:
                return TextConstants.objectRecognitionShort
            case .photoPick:
                return TextConstants.photoPickShort
            }
        }

        var image: UIImage? {
            switch self {
            case .backUp:
                return UIImage(named: "back_up_HQ")
            case .contacts:
                return UIImage(named: "contacts")
            case .places:
                return UIImage(named: "place_recognition")
            case .face:
                return UIImage(named: "face_recognition")
            case .object:
                return UIImage(named: "object_recognition")
            case .photoPick:
                return UIImage(named: "photo_pick")
            }
        }
    }
    
    internal var currentFeatureIndex: Int = 0 {
        didSet {
            if currentFeatureIndex == Feature.allFeatureTypes.count {
                currentFeatureIndex = 0
            }
        }
    }
    
    private let transition = CATransition()
    private var imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private var timer: Timer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }

    private func setup() {
        addSubview(imageView)
        addSubview(descriptionLabel)
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: NumericConstants.imageViewSizeForPremiumFeaturesView,
                                 height: NumericConstants.imageViewSizeForPremiumFeaturesView)
        descriptionLabel.frame = .zero
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.TurkcellSaturaMedFont(size: 14)
        descriptionLabel.textColor = ColorConstants.darkText

        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: NumericConstants.imageViewSizeForPremiumFeaturesView).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 7).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        changeFrame()
        
        timer = Timer.scheduledTimer(timeInterval: NumericConstants.timeIntervalForPremiumFeaturesView,
                                     target: self,
                                     selector: #selector(changeFrame),
                                     userInfo: nil,
                                     repeats: true)
        setupAnimation()
    }

    deinit {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    @objc func changeFrame() {
        descriptionLabel.layer.add(transition, forKey: kCATransitionFade)
        imageView.layer.add(transition, forKey: kCATransitionFade)
        
        descriptionLabel.text = Feature.allFeatureTypes[currentFeatureIndex].title
        imageView.image = Feature.allFeatureTypes[currentFeatureIndex].image
        
        currentFeatureIndex += 1
    }
    
    private func setupAnimation() {
        transition.duration = NumericConstants.transitionDurationForPremiumFeaturesView
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
    }
}
