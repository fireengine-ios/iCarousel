//
//  PackageInfoView.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum ControlPackageType {
    case myProfile
    case myStorage
    case premiumBanner
    
    case accountType(ControlPackageType.AccountType)
    
    enum AccountType {
        case standard
        case middle
        case premium
        
        var text: String {
            switch self {
            case .standard:
                return TextConstants.standard
            case .middle:
                return TextConstants.standardPlus
            case .premium:
                return TextConstants.premium
            }
        }
        
        var leavePremiumType: LeavePremiumType {
            switch self {
            case .standard:
                return .standard
            case .middle:
                return .middle
            case .premium:
                return .premium
            }
        }
    }
}

protocol PackageInfoViewDelegate: class {
    func onSeeDetailsTap(with type: ControlPackageType)
}

final class PackageInfoView: UIView, NibInit {

    //MARK: IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var seeDetailsLabel: UILabel!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var shadowView: UIView!

    //MARK: vars
    private var packagePremiumView: PackagePremiumView?
    private var viewType: ControlPackageType!
    weak var delegate: PackageInfoViewDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()

        setupDesign()
        setupShadow()
        setupGesture()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setupShadow()
    }

    //MARK: Utility methods(public)
    func configure(with type: ControlPackageType, percentage: CGFloat? = nil) {
        viewType = type

        switch type {
        case .myProfile:
            titleLabel.text = TextConstants.myProfile
            detailLabel.isHidden = true
        case .myStorage:
            titleLabel.text = TextConstants.myStorage
            if let percentage = percentage, percentage != 0 {
                detailLabel.isHidden = false
                detailLabel.text = String(format: TextConstants.usagePercentage, percentage.rounded(.toNearestOrAwayFromZero))
            } else {
                detailLabel.isHidden = true
            }
        case .premiumBanner:
            let packagePremiumView = PackagePremiumView.initFromNib()
            addSubview(packagePremiumView)
            
            packagePremiumView.translatesAutoresizingMaskIntoConstraints = false

            packagePremiumView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            packagePremiumView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            packagePremiumView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            packagePremiumView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            
            self.packagePremiumView = packagePremiumView
            seeDetailsLabel.isHidden = true
        case .accountType(let accountType):
            titleLabel.text = TextConstants.accountType
            
            detailLabel.text = accountType.text
        }
    }

    //MARK: Utility methods(private)
    private func setupDesign() {
        titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        seeDetailsLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
        detailLabel.font = UIFont.TurkcellSaturaMedFont(size: 16)

        titleLabel.textColor = ColorConstants.textGrayColor
        seeDetailsLabel.textColor = ColorConstants.blueColor
        detailLabel.textColor = ColorConstants.textGrayColor
        
        seeDetailsLabel.text = TextConstants.seeDetails
        titleLabel.adjustsFontSizeToFitWidth()
    }

    private func setupShadow() {

        layer.cornerRadius = NumericConstants.packageViewCornerRadius
        packagePremiumView?.layer.cornerRadius = NumericConstants.packageViewCornerRadius
        bottomView.layer.cornerRadius = NumericConstants.packageViewCornerRadius

        clipsToBounds = false

        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = NumericConstants.packageViewShadowOpacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = NumericConstants.packageViewMainShadowRadius
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: 0,
                                                     width: layer.frame.size.width,
                                                     height: layer.frame.size.height)).cgPath

        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowOpacity = NumericConstants.packageViewShadowOpacity
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowRadius = NumericConstants.packageViewBottomViewShadowRadius
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSeeDetailsTap))
        self.addGestureRecognizer(tap)
    }

    //MARK: objc
    @objc func onSeeDetailsTap() {
        delegate.onSeeDetailsTap(with: viewType)
    }
}
