//
//  PackageInfoView.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum ControlPackageType {
    case myStorage
    case premiumUser
    case standard
}

protocol PackageInfoViewDelegate: class {
    func onSeeDetailsTap(with type: ControlPackageType)
}

final class PackageInfoView: UIView, NibInit {

    //MARK: IBOutlet
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var seeDetailsLabel: UILabel!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var storageSizeLabel: UILabel!
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
    func configure(with type: ControlPackageType) {

        viewType = type

        switch type {
        case .myStorage:
            titleLabel.text = TextConstants.myStorage
            seeDetailsLabel.text = TextConstants.seeDetails
            storageSizeLabel.text = "105 GB"
        case .premiumUser:
            titleLabel.text = TextConstants.premiumUser
            seeDetailsLabel.text = TextConstants.seeDetails
            storageSizeLabel.isHidden = true
        case .standard:
            packagePremiumView = PackagePremiumView.initFromNib()
            guard let becomePremiumView = packagePremiumView else { return }
            addSubview(becomePremiumView)
            packagePremiumView = becomePremiumView

            packagePremiumView?.translatesAutoresizingMaskIntoConstraints = false

            packagePremiumView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
            packagePremiumView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            packagePremiumView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            packagePremiumView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
    }

    //MARK: Utility methods(private)
    private func setupDesign() {
        titleLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        seeDetailsLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
        storageSizeLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)

        titleLabel.textColor = ColorConstants.textGrayColor
        seeDetailsLabel.textColor = ColorConstants.blueColor
        storageSizeLabel.textColor = ColorConstants.textGrayColor
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
        bottomView.addGestureRecognizer(tap)
    }

    //MARK: objc
    @objc func onSeeDetailsTap() {
        delegate.onSeeDetailsTap(with: viewType)
    }
}
