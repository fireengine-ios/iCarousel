//
//  FunTabBar.swift
//  Depo
//
//  Created by Andrei Novikau on 10/7/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol FunTabBarDelegate: class {
    func didSelectItem(_ type: AttachedEntityType)
}

final class FunTabBar: UIView {
    
    private let contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
    
    weak var delegate: FunTabBarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.photoEditBackgroundColor
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.pinToSuperviewEdges()
        
        setupUI()
    }
    
    private func setupUI() {
        let leftSpacer = UIView()
        let rightSpacer = UIView()

        contentView.addArrangedSubview(leftSpacer)
        
        let types = AttachedEntityType.allCases
        types.forEach { type in
            let item = FunTabBarItem.with(type: type)
            item.addTarget(self, action: #selector(onSelectItem(_:)), for: .touchUpInside)
            contentView.addArrangedSubview(item)
            
            if type != types.last {
                let inlineSpacer = UIView()
                contentView.addArrangedSubview(inlineSpacer)
                
                if Device.isIpad {
                    inlineSpacer.widthAnchor.constraint(equalToConstant: 50).activate()
                } else {
                    leftSpacer.widthAnchor.constraint(equalTo: inlineSpacer.widthAnchor).activate()
                }
            }
        }
        
        contentView.addArrangedSubview(rightSpacer)
        
        leftSpacer.widthAnchor.constraint(equalTo: rightSpacer.widthAnchor).activate()
    }
    
    @objc private func onSelectItem(_ sender: FunTabBarItem) {
        delegate?.didSelectItem(sender.type)
    }
}

final class FunTabBarItem: UIButton {
    
    static func with(type: AttachedEntityType) -> FunTabBarItem {
        let button = FunTabBarItem(type: .custom)
        button.setup(with: type)
        button.centerVertically()
        return button
    }
    
    private(set) var type: AttachedEntityType = .gif
    
    private var oldFrame = CGRect.zero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if oldFrame != frame {
            oldFrame = frame
            centerVertically()
        }
    }
    
    func setup(with type: AttachedEntityType) {
        self.type = type
        
        setImage(type.normalImage, for: .normal)
        setImage(type.selectedImage, for: .highlighted)
        setImage(type.selectedImage, for: .selected)
        setTitle(type.title, for: .normal)
        
        setTitleColor(.white, for: .normal)
        setTitleColor(.lrTealish, for: .highlighted)
        setTitleColor(.lrTealish, for: .selected)
        
        titleLabel?.font = .TurkcellSaturaMedFont(size: Device.isIpad ? 15 : 12)
    }
}
