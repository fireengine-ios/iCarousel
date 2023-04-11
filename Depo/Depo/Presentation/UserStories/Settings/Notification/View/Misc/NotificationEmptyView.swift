//
//  NotificationEmptyView.swift
//  Depo
//
//  Created by yilmaz edis on 21.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

class NotificationEmptyView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 16)
        view.textColor = AppColor.label.color
        view.textAlignment = .center
        view.numberOfLines = 0
        view.text = localized(.notificationsNoNotification)
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var emptyImageView: UIImageView = {
        let view = UIImageView()
        view.image = Image.popupSuccessful.image
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setLayout(with parent: UIView) {
        parent.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: parent.topAnchor, constant: 115).activate()
        leadingAnchor.constraint(equalTo: parent.leadingAnchor).activate()
        trailingAnchor.constraint(equalTo: parent.trailingAnchor).activate()
        
        addSubview(emptyImageView)
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.topAnchor.constraint(equalTo: topAnchor).activate()
        emptyImageView.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 55).activate()
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).activate()
    }
}
