//
//  BackButton.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 4/9/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class BackButtonItem: UIBarButtonItem {
    convenience init(action: @escaping VoidHandler) {
        let button = BackButton(action: action)
        self.init(customView: button)
    }
}

final class BackButton: UIButton {
    
    private var action: VoidHandler?
    
    convenience init(action: @escaping VoidHandler) {
        let rect = CGRect(x: 0, y: 0, width: 60, height: 44)
        self.init(frame: rect)
        self.action = action
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var buttonColor: UIColor {
        get {
            return tintColor
        }
        set (color) {
            tintColor = color
            setTitleColor(color, for: .normal)
            setTitleColor(color.darker(by: 40), for: .highlighted)
        }
    }
    
    private func setup() {
        buttonColor = ColorConstants.whiteColor
        
        contentHorizontalAlignment = .left
        titleEdgeInsets.left = 8
        
        setTitle(TextConstants.backTitle, for: .normal)
        setImage(UIImage(named: "im_backButton"), for: .normal)
        titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 19)
        addTarget(self, action: #selector(actionTouchUp), for: .touchUpInside)
    }
    
    @objc func actionTouchUp() {
        action?()
    }
}
