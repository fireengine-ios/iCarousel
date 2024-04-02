//
//  RaffleSummaryCollectionViewCell.swift
//  Depo
//
//  Created by Ozan Salman on 30.03.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import Foundation

protocol RaffleSummaryCollectionViewCellDelegate: AnyObject {
    func didActionButtonTapped(raffle: RaffleElement)
}

class RaffleSummaryCollectionViewCell: UICollectionViewCell {
    
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
        view.font = .appFont(.medium, size: 14)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .center
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var summaryLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.light, size: 10)
        view.textColor = AppColor.label.color
        view.numberOfLines = 0
        view.textAlignment = .center
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    private lazy var actionButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.font = .appFont(.medium, size: 10)
        view.setTitleColor(AppColor.darkBlueColor.color, for: .normal)
        view.setTitleColor(AppColor.darkBlueColor.color, for: .selected)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.layer.borderWidth = 1.0
        view.layer.borderColor = AppColor.darkBlueColor.cgColor
        view.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        view.isHidden = false
        return view
    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var infoLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 10)
        view.textColor = AppColor.profileInfoOrange.color
        view.text = localized(.gamificationComeback)
        view.numberOfLines = 0
        view.textAlignment = .center
        view.lineBreakMode = .byWordWrapping
        view.isHidden = true
        return view
    }()
    
    private lazy var comeBackLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.medium, size: 10)
        view.textColor = AppColor.profileInfoOrange.color
        view.text = localized(.gamificationComeback)
        view.numberOfLines = 0
        view.textAlignment = .center
        view.lineBreakMode = .byWordWrapping
        view.isHidden = true
        return view
    }()
    
    weak var delegate: RaffleSummaryCollectionViewCellDelegate?
    private var raffle: RaffleElement?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(raffle: RaffleElement, imageOppacity: Float, statusResponse: RaffleStatusResponse?) {
        self.raffle = raffle
        iconImage.image = raffle.icon
        titleLabel.text = raffle.title
        iconImage.layer.opacity = imageOppacity
        actionButton.setTitle(raffle.title, for: .normal)
        infoLabel.text = raffle.infoLabelText
        
        var mainText: String = ""
        let transactionCountText = "%d kez"
        let pointCountText = "%d çekiliş puanı"
        var transactionCount: Int = 0
        var pointCount: Int = 0
        var isHaveDetail: Bool = false
        
        for status in statusResponse?.details ?? [] {
            if raffle.rawValue == status.earnType {
                mainText = raffle.detailText
                transactionCount = status.transactionCount ?? 0
                pointCount = status.totalPointsEarnedRule ?? 0
                isHaveDetail = true
                if status.dailyRemainingPoints == 0 {
                    actionButton.isHidden = true
                    infoLabel.isHidden = false
                    comeBackLabel.isHidden = false
                } else {
                    actionButton.isHidden = false
                    infoLabel.isHidden = true
                    comeBackLabel.isHidden = true
                }
                break
            } else {
                mainText = raffle.detailTextNoAction
                transactionCount = 0
                pointCount = 0
                isHaveDetail = false
                actionButton.isHidden = false
                infoLabel.isHidden = true
                comeBackLabel.isHidden = true
            }
        }
        
        if isHaveDetail {
            let content = NSMutableAttributedString(string: mainText, attributes: [.font: UIFont.appFont(.light, size: 10)])
            let transaction = NSAttributedString(string: String(format: transactionCountText, transactionCount), attributes: [.font: UIFont.appFont(.bold, size: 10)])
            let point = NSAttributedString(string: String(format: pointCountText, pointCount), attributes: [.font: UIFont.appFont(.bold, size: 10)])
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 14
            paragraphStyle.alignment = .center
            content.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, content.length))
            summaryLabel.attributedText = NSAttributedString(format: content, args: transaction, point)
        } else {
            let content = NSMutableAttributedString(string: mainText, attributes: [.font: UIFont.appFont(.light, size: 10)])
            let point = NSAttributedString(string: String(format: pointCountText, pointCount), attributes: [.font: UIFont.appFont(.bold, size: 10)])
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 14
            paragraphStyle.alignment = .center
            content.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, content.length))
            summaryLabel.attributedText = NSAttributedString(format: content, args: point)
        }
    }
    
    @objc private func actionButtonTapped() {
        if let raffle = raffle {
            delegate?.didActionButtonTapped(raffle: raffle)
        }
    }
}

extension RaffleSummaryCollectionViewCell {
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
        
        addSubview(summaryLabel)
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).activate()
        summaryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).activate()
        summaryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).activate()
        
        addSubview(infoView)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20).activate()
        infoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).activate()
        infoView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).activate()
        infoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).activate()
        
        infoView.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 0).activate()
        actionButton.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 0).activate()
        actionButton.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: 0).activate()
        actionButton.bottomAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 0).activate()
        
        infoView.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 0).activate()
        infoLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 0).activate()
        infoLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: 0).activate()
        infoLabel.heightAnchor.constraint(equalToConstant: 20).activate()
        
        infoView.addSubview(comeBackLabel)
        comeBackLabel.translatesAutoresizingMaskIntoConstraints = false
        comeBackLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 0).activate()
        comeBackLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 0).activate()
        comeBackLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: 0).activate()
        comeBackLabel.heightAnchor.constraint(equalToConstant: 20).activate()
    }
}

public extension NSAttributedString {
    convenience init(format: NSAttributedString, args: NSAttributedString...) {
        let mutableNSAttributedString = NSMutableAttributedString(attributedString: format)

        args.forEach { (attributedString) in
            let range = NSString(string: mutableNSAttributedString.string).range(of: "%@")
            mutableNSAttributedString.replaceCharacters(in: range, with: attributedString)
        }
        self.init(attributedString: mutableNSAttributedString)
    }
}
