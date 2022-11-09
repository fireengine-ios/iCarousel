//
//  CustomSegmentedView.swift
//  Depo
//
//  Created by yilmaz edis on 9.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class CustomSegmentedView: UIView {
    
    var action: IntHandler?
    private var buttons = [InsetsButton]()
    
    lazy var stackView: UIStackView = {
        let newValue = UIStackView()
        newValue.spacing = 8
        newValue.axis = .horizontal
        newValue.alignment = .fill
        newValue.distribution = .fill
        newValue.isOpaque = true
        return newValue
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        setupStackView()
    }
    
    private func setupStackView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
    }
    
    func insertSegment(withTitle title: String, tag: Int) {
        let segmentButton = getSegmentButton(withTitle: title, tag: tag)
        let shadowView = getShadowView()
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.widthAnchor.constraint(equalToConstant: 112).activate()
        shadowView.heightAnchor.constraint(equalToConstant: 40).activate()
        
        shadowView.addSubview(segmentButton)
        segmentButton.translatesAutoresizingMaskIntoConstraints = false
        segmentButton.pinToSuperviewEdges()
        buttons.append(segmentButton)
        stackView.addArrangedSubview(shadowView)
    }
    
    private func getShadowView() -> UIView {
        let view = UIView()
        view.addRoundedShadows(cornerRadius: 12, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
        return view
    }
    
    private func getSegmentButton(withTitle title: String, tag: Int) -> InsetsButton {
        let button = InsetsButton()
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .appFont(.medium, size: 16)
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        action?(sender.tag)
        renderSegmentButtons(segment: sender.tag)
    }
    
    func renderSegmentButtons(segment: Int) {
        for el in buttons {
            if el.tag == segment {
                el.setBackgroundColor(AppColor.tint.color, for: .normal)
                el.setTitleColor(.white, for: .normal)
            } else {
                el.setBackgroundColor(AppColor.tertiaryBackground.color, for: .normal)
                el.setTitleColor(AppColor.label.color, for: .normal)
            }
        }
    }
}
