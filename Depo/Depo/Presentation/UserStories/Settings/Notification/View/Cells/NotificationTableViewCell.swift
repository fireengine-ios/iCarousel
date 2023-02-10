//
//  NotificationTableViewCell.swift
//  Depo
//
//  Created by yilmaz edis on 10.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.regular, size: 14)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.regular, size: 14)
        view.textColor = AppColor.billoGrayAndWhite.color
        view.textAlignment = .right
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var infoImageView: UIImageView = {
        let view = UIImageView()
        
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setLayout()
    }
    
    private func setLayout() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).activate()
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).activate()
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).activate()
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).activate()
        
    }
    
    func configure(model: NotificationModel) {
        titleLabel.text = model.title
        descriptionLabel.text = model.description
    }
}
