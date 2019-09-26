//
//  TimelineButton.swift
//  Depo
//
//  Created by Andrei Novikau on 9/23/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class TimelineButton: UIButton {
            
    enum State {
        case enabled
        case disabled
        case photosPreparation
    }
    
    private let borderColor = UIColor.white
    var visibleState = State.enabled {
        didSet {
            switch visibleState {
            case .enabled:
                layer.borderColor = borderColor.cgColor
                label.alpha = 1
                loadingImage.isHidden = true
            case .disabled:
                layer.borderColor = borderColor.withAlphaComponent(0.5).cgColor
                label.alpha = 0.5
                loadingImage.isHidden = true
            case .photosPreparation:
                layer.borderColor = borderColor.withAlphaComponent(0.5).cgColor
                label.alpha = 0.5
                loadingImage.isHidden = false
                rotate()
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.5 : 1
        }
    }
    
    private let loadingImage = UIImageView(image: UIImage(named: "timelineLoadingIcon"))
    private let label = UILabel()
    private var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setTitle(nil, for: .normal)
        setImage(nil, for: .normal)
        
        let stackView = UIStackView()
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 0
        addSubview(stackView)

        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
        loadingImage.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(loadingImage)
        
        loadingImage.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loadingImage.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        label.text = TextConstants.TBMatic.Photos.seeTimeline
        label.textColor = .white
        label.backgroundColor = .clear
        label.font = UIFont.TurkcellSaturaDemFont(size: 18)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(label)
        
        layer.masksToBounds = true
        layer.cornerRadius = bounds.height * 0.5
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }
    
    private var rotationAngle: CGFloat = 0
    private func rotate() {
        guard visibleState == .photosPreparation else {
            return
        }
        
        if rotationAngle == .pi * 2 {
            rotationAngle = 0
        }
        rotationAngle += .pi
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
            self.loadingImage.transform = CGAffineTransform(rotationAngle: self.rotationAngle)
        }, completion: { [weak self] _ in
            self?.rotate()
        })
    }
}
