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
                timeLineLabel.alpha = 1
                loadingImage.isHidden = true
                isUserInteractionEnabled = true
            case .disabled:
                layer.borderColor = borderColor.withAlphaComponent(0.5).cgColor
                timeLineLabel.alpha = 0.5
                loadingImage.isHidden = true
                isUserInteractionEnabled = false
            case .photosPreparation:
                layer.borderColor = borderColor.withAlphaComponent(0.5).cgColor
                timeLineLabel.alpha = 0.5
                loadingImage.isHidden = false
                isUserInteractionEnabled = false
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
    private let timeLineLabel = UILabel()
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
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
        
        timeLineLabel.text = TextConstants.tbMaticPhotosSeeTimeline
        timeLineLabel.textColor = .white
        timeLineLabel.backgroundColor = .clear
        timeLineLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        timeLineLabel.textAlignment = .center
        timeLineLabel.numberOfLines = 2
        timeLineLabel.lineBreakMode = .byWordWrapping
        stackView.addArrangedSubview(timeLineLabel)
        
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
