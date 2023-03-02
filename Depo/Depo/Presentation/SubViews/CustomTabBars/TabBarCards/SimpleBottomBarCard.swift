//
//  SimpleBottomBarCard.swift
//  Depo
//
//  Created by yilmaz edis on 20.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

protocol SimpleBottomBarCardDelegate: AnyObject {
    func cancelButtonAction()
}

class SimpleBottomBarCard: UIView {
    
    private lazy var countLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(.regular, size: 12)
        view.textColor = .white
        view.textAlignment = .left
        return view
    }()
    
    private lazy var cancelButton: RoundedButton = {
        let view = RoundedButton()
        view.backgroundColor = .clear
        view.setTitle(TextConstants.cancel, for: .normal)
        view.titleLabel?.font = .appFont(.regular, size: 12)
        view.setTitleColor(.white, for: .normal)
        view.setTitleColor(.white.darker(by: 30), for: .highlighted)
        return view
    }()
    
    weak var delegate: SimpleBottomBarCardDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        backgroundColor = AppColor.tint.color
        layer.cornerRadius = 16
        isHidden = true
        
        cancelButton.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
    }
    
    @objc private func cancelButtonAction() {
        delegate?.cancelButtonAction()
    }
    
    func setCount(with count: Int) {
        countLabel.text = "\(count) \( count == 0 ? "" : TextConstants.accessibilitySelected)"
    }
    
    func setLayout(with parent: UIView) {
        parent.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 12).activate()
        trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -12).activate()
        bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -90).activate()
        heightAnchor.constraint(equalToConstant: 68).activate()
        
        addSubview(countLabel)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).activate()
        countLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).activate()
        
        addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).activate()
        cancelButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).activate()
    }
    
}
