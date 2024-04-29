//
//  RaffleCollectionViewCell.swift
//  Depo
//
//  Created by Ozan Salman on 28.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import UIKit

protocol RaffleCollectionViewCellDelegate: AnyObject {
    func didImageTapped(raffle: RaffleElement)
}

class RaffleCollectionViewCell: UICollectionViewCell {
    
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
        view.isUserInteractionEnabled = true
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        view.addGestureRecognizer(tapImage)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 14)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .center
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var nextDayLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 10)
        view.textColor = AppColor.forgetPassTimer.color
        view.numberOfLines = 0
        view.textAlignment = .center
        view.lineBreakMode = .byWordWrapping
        view.text = localized(.gamificationComeback)
        //view.isHidden = true
        return view
    }()
    
    weak var delegate: RaffleCollectionViewCellDelegate?
    private var raffle: RaffleElement?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(raffle: RaffleElement, imageOppacity: Float, nextLabelIsHidden: Bool, period: String) {
        self.raffle = raffle
        iconImage.image = raffle.icon
        titleLabel.text = raffle.title
        iconImage.layer.opacity = imageOppacity
        //nextDayLabel.isHidden = nextLabelIsHidden
        if nextLabelIsHidden { // hak var
            nextDayLabel.text = localized(.gamificationRaffleWin)
        } else { //hak yok
            nextDayLabel.text = String(format: localized(.gamificationEventCompleted), period)
        }
    }
    
    @objc private func imageTapped() {
        if let raffle = raffle {
            delegate?.didImageTapped(raffle: raffle)
        }
    }
}

extension RaffleCollectionViewCell {
    private func setLayout() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: topAnchor, constant: 10).activate()
        containerView.heightAnchor.constraint(equalToConstant: 45).activate()
        containerView.widthAnchor.constraint(equalToConstant: 45).activate()
        containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).activate()
        
        containerView.addSubview(iconImage)
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2).activate()
        iconImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2).activate()
        iconImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2).activate()
        iconImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2).activate()
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 10).activate()
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).activate()
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).activate()
        
        addSubview(nextDayLabel)
        nextDayLabel.translatesAutoresizingMaskIntoConstraints = false
        nextDayLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).activate()
        nextDayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).activate()
        nextDayLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2).activate()
    }
}
