//
//  PremiumFeaturesView.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 11/17/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PremiumFeaturesView: UIView {
    
    internal var currentFrame: Int = 0 {
        didSet {
            if currentFrame == C.sequence.count {
                currentFrame = 0
            }
        }
    }
    
    let transition = CATransition()
    var imageView = UIImageView()
    let descriptionLabel = UILabel()
    var timer: Timer? = Timer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func setup() {
                
        addSubview(imageView)
        addSubview(descriptionLabel)
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: C.imageViewSize, height: C.imageViewSize)
        descriptionLabel.frame = .zero
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.TurkcellSaturaMedFont(size: 14)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: C.imageViewSize).isActive = true
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
        if let t = timer {
            t.invalidate()
            timer = nil
        }
    }
    
    @objc func changeFrame() {
        
        descriptionLabel.layer.add(transition, forKey: kCATransitionFade)
        imageView.layer.add(transition, forKey: kCATransitionFade)
        
        descriptionLabel.text = C.sequence[currentFrame].title
        imageView.image = C.sequence[currentFrame].image
        
        currentFrame += 1
    }
    
    func setupAnimation() {
        
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
    }
}

private enum C {
    
    static let imageViewSize: CGFloat = 46
    static let sequence: [Description] = [.backUp, .contacts, .places, .face, .object]
    static let horizonSpace: CGFloat = 9
    
    enum Description: String {
        case backUp
        case contacts
        case places
        case face
        case object

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
            }
        }
    }
}
