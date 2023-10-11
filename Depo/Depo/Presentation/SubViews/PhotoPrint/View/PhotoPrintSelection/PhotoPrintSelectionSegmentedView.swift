//
//  PhotoPrintSelectionSegmentedView.swift
//  Depo
//
//  Created by Ozan Salman on 24.07.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

final class PhotoPrintSelectionSegmentedView: UIView {
    
    private let topView = UIView()
    let containerView = UIView()
    private let transparentGradientView = TransparentGradientView(style: .vertical,
                                                                  mainColor: AppColor.primaryBackground.color)
    
    var subViewForInfoHeightConstraint: NSLayoutConstraint? = nil
    
    lazy var segmentedControl: CustomSegmentedView = {
        let segmentedControl = CustomSegmentedView()
        return segmentedControl
    }()
    
    let subViewForInfo: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.background.color
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()
    
    let selectedTextLabel: UILabel = {
       let label = UILabel()
        label.font = .appFont(.regular, size: 12)
        label.textColor = AppColor.tealBlue.color
        return label
    }()
    
    let constLabel: UILabel = {
       let label = UILabel()
        label.font = .appFont(.regular, size: 16)
        label.text = localized(.selectedForPrint)
        label.textColor = AppColor.label.color
        return label
    }()
    
    let actionButton: DarkBlueButton = {
        let button = DarkBlueButton()
        button.titleLabel?.font = .appFont(.medium, size: 16)
        button.setTitle(localized(.deleteAccountContinueButton), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.adjustsFontSizeToFitWidth()
        button.isHidden = true
        return button
    }()
    
    private let needShowSegmentedControll: Bool = true

    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        assertionFailure()
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = AppColor.primaryBackground.color
        topView.backgroundColor = AppColor.primaryBackground.color
        containerView.backgroundColor = AppColor.primaryBackground.color
        setupLayout()
    }
    
    private func setupLayout() {
        let view = self
        view.addSubview(topView)
        topView.addSubview(segmentedControl)
        view.addSubview(containerView)
        view.addSubview(transparentGradientView)
        view.addSubview(subViewForInfo)
        subViewForInfo.addSubview(selectedTextLabel)
        subViewForInfo.addSubview(actionButton)
        subViewForInfo.addSubview(constLabel)
        
        let edgeOffset: CGFloat = Device.isIpad ? 40 : 12
        let transparentGradientViewHeight = NumericConstants.instaPickSelectionSegmentedTransparentGradientViewHeight
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.topAnchor.constraint(equalTo: view.topAnchor).activate()
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeOffset).activate()
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeOffset).activate()
        topView.heightAnchor.constraint(equalToConstant: 56).activate()
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.leadingAnchor.constraint(equalTo: topView.leadingAnchor).activate()
        segmentedControl.trailingAnchor.constraint(equalTo: topView.trailingAnchor).activate()
        segmentedControl.centerYAnchor.constraint(equalTo: topView.centerYAnchor).activate()
        segmentedControl.heightAnchor.constraint(equalToConstant: 40).activate()
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let topAnchor = needShowSegmentedControll ? topView.bottomAnchor : view.topAnchor
        containerView.topAnchor.constraint(equalTo: topAnchor).activate()
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        
        transparentGradientView.translatesAutoresizingMaskIntoConstraints = false
        transparentGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        transparentGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        transparentGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        transparentGradientView.heightAnchor.constraint(equalToConstant: transparentGradientViewHeight).activate()
        
        subViewForInfo.translatesAutoresizingMaskIntoConstraints = false
        subViewForInfo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).activate()
        subViewForInfo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).activate()
        subViewForInfo.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).activate()
        subViewForInfoHeightConstraint = subViewForInfo.heightAnchor.constraint(equalToConstant: 90)
        subViewForInfoHeightConstraint?.isActive = true
        
        selectedTextLabel.translatesAutoresizingMaskIntoConstraints = false
        selectedTextLabel.trailingAnchor.constraint(equalTo: subViewForInfo.trailingAnchor, constant: -20).activate()
        selectedTextLabel.topAnchor.constraint(equalTo: subViewForInfo.topAnchor, constant: 20).activate()
        selectedTextLabel.heightAnchor.constraint(equalToConstant: 25).activate()
        
        constLabel.translatesAutoresizingMaskIntoConstraints = false
        constLabel.leadingAnchor.constraint(equalTo: subViewForInfo.leadingAnchor, constant: 20).activate()
        constLabel.topAnchor.constraint(equalTo: subViewForInfo.topAnchor, constant: 20).activate()
        constLabel.heightAnchor.constraint(equalToConstant: 25).activate()
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.topAnchor.constraint(equalTo: constLabel.bottomAnchor, constant: 15).activate()
        actionButton.leadingAnchor.constraint(equalTo: subViewForInfo.leadingAnchor, constant: 20).activate()
        actionButton.trailingAnchor.constraint(equalTo: subViewForInfo.trailingAnchor, constant: -20).activate()
        actionButton.heightAnchor.constraint(equalToConstant: 45).activate()
    }
}

