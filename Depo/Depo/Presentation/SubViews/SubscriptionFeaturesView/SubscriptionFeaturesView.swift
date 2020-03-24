//
//  SubscriptionFeaturesView.swift
//  Depo
//
//  Created by Raman Harhun on 2/21/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class SubscriptionFeaturesView: UIView {
    
    enum Features {
        case storageOnly
        case recommended(features: [AuthorityType])
        case features(_ features: [AuthorityType])
    }
    
    private lazy var stackView: UIStackView = {
        let newValue = UIStackView()
        newValue.axis = .vertical
        newValue.spacing = 1
        return newValue
    }()
    
    private lazy var showButton: UIButton = {
        let newValue = UIButton()
        newValue.setTitle(TextConstants.showMore, for: .normal)
        newValue.setTitleColor(UIColor.lrTealishTwo, for: .normal)
        
        newValue.setTitle(TextConstants.showLess, for: .selected)
        newValue.setTitleColor(ColorConstants.coolGrey, for: .selected)
        
        newValue.addTarget(self, action: #selector(onCollapseTap), for: .touchUpInside)
        
        newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
        
        return newValue
    }()
    
    private lazy var dividerLineView: UIView = {
        let newValue = UIView()
        newValue.backgroundColor = ColorConstants.lightGrayColor
        return  newValue
    }()
    
    private var features: Features = .features([])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubviews()
        makeConstraints()
    }
    
    func configure(features: Features) {
        self.features = features
        prepateInitialState()
    }
    
    private func addSubviews() {
        addSubview(stackView)
        addSubview(showButton)
        addSubview(dividerLineView)
    }
    
    private func makeConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor).activate()
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).activate()
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).activate()
        stackView.bottomAnchor.constraint(equalTo: dividerLineView.topAnchor, constant: -8).activate()
        
        showButton.translatesAutoresizingMaskIntoConstraints = false
        showButton.heightAnchor.constraint(equalToConstant: 40).activate()
        showButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).activate()
        showButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).activate()
        showButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).activate()
        
        dividerLineView.translatesAutoresizingMaskIntoConstraints = false
        dividerLineView.heightAnchor.constraint(equalToConstant: 1).activate()
        dividerLineView.bottomAnchor.constraint(equalTo: self.showButton.topAnchor).activate()
        dividerLineView.leadingAnchor.constraint(equalTo: self.showButton.leadingAnchor).activate()
        dividerLineView.trailingAnchor.constraint(equalTo: self.showButton.trailingAnchor).activate()
    }
    
    private func prepateInitialState() {
        switch features {
        case .storageOnly:
            removeCollapseButton(offsetFromBottom: 0)

        case .features:
            break
            
        case .recommended(features: let features):
            removeCollapseButton(offsetFromBottom: -8)
            addFeatures(features)
        }
    }
    
    private func removeCollapseButton(offsetFromBottom constant: CGFloat) {
        showButton.removeFromSuperview()
        dividerLineView.removeFromSuperview()
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: constant).activate()
    }
    
    private func addFeatures(_ features: [AuthorityType]) {
        for feature in features {
            let label = UILabel()
            label.text = feature.description
            label.font = UIFont.TurkcellSaturaFont(size: 16)
            label.textColor = ColorConstants.darkText
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
    }
    
    private func hideFeatures() {
        stackView.arrangedSubviews
            .forEach {
                stackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
        }
    }
    
    @objc private func onCollapseTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if sender.isSelected {
            switch features {
            case .recommended, .storageOnly:
                ///expanded by default
                break
                
            case .features(let features):
                addFeatures(features)
            }
        } else {
            hideFeatures()
        }
    }
}
