//
//  CarouselPageView.swift
//  Depo_LifeTech
//
//  Created by ÜNAL ÖZTÜRK on 13.12.2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CarouselPageView : UIView {
    
    let titleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.TurkcellSaturaDemFont(size: 18)
        label.textColor = ColorConstants.textGrayColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.TurkcellSaturaFont(size: 12)
        label.textColor = ColorConstants.textGrayColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo:trailingAnchor),
        ])
        
        addSubview(textLabel)
        NSLayoutConstraint.activate([
                textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                textLabel.trailingAnchor.constraint(equalTo:trailingAnchor),
                textLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        
    }
    
    func setModel(model: CarouselPageModel) {
        textLabel.text = model.text
        titleLabel.text = model.title
    }
    
}
