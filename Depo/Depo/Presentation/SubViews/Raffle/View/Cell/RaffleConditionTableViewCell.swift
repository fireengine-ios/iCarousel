//
//  RaffleConditionTableViewCell.swift
//  Depo
//
//  Created by Ozan Salman on 15.04.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

final class RaffleConditionTableViewCell: UITableViewCell {
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = .white
        view.layer.borderWidth = 1.0
        view.layer.borderColor = AppColor.raffleView.cgColor
        return view
    }()
    
    private lazy var iconImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 5
        view.backgroundColor = .blue
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 12)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var summaryLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 10)
        view.textColor = AppColor.profileInfoOrange.color
        view.numberOfLines = 0
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
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
    
    func configure(raffle: RaffleElement, imageOppacity: Float, earnCount: Int) {
        backgroundColor = AppColor.raffleCondition.color
        iconImage.image = raffle.icon
        iconImage.layer.opacity = imageOppacity
        titleLabel.text = raffle.title
        //summaryLabel.text = String(format: raffle.earnLabelText, earnCount)
    }
}

extension RaffleConditionTableViewCell {
    private func setLayout() {
        heightAnchor.constraint(equalToConstant: 55).activate()
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 0).activate()
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).activate()
        containerView.heightAnchor.constraint(equalToConstant: 45).activate()
        containerView.widthAnchor.constraint(equalToConstant: 45).activate()
        
        containerView.addSubview(iconImage)
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2).activate()
        iconImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2).activate()
        iconImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2).activate()
        iconImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2).activate()
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2).activate()
        titleLabel.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 10).activate()
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).activate()
        titleLabel.heightAnchor.constraint(equalToConstant: 20).activate()
        
        addSubview(summaryLabel)
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).activate()
        summaryLabel.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 10).activate()
        summaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).activate()
        summaryLabel.heightAnchor.constraint(equalToConstant: 20).activate()
    }
}
