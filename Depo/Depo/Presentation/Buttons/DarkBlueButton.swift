//
//  DarkBlueButton.swift
//  Depo
//
//  Created by Burak Donat on 19.10.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

class DarkBlueButton: InsetsButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurate()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setCornerRadius()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setCornerRadius()
    }
    
    func configurate() {
        self.setBackgroundColor(AppColor.button.color, for: .normal)
        self.setBackgroundColor(AppColor.button.color.withAlphaComponent(0.5), for: .disabled)
        self.setBackgroundColor(AppColor.button.color.darker(by: 30), for: .highlighted)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .appFont(.medium, size: 16)
        layer.masksToBounds = true

        setCornerRadius()
        adjustsFontSizeToFitWidth()
    }
    
    func setCornerRadius() {
        guard bounds.height > 0 else {
            return
        }
        layer.cornerRadius = bounds.height * 0.5
        
        setInsets()
    }

    func setInsets() {
        let inset = frame.height * 0.3
        let isAddedImaged = image(for: .normal) != nil
        let leftInset: CGFloat = isAddedImaged ? 0.0 : inset
        insets = UIEdgeInsets(top: 0.0, left: leftInset, bottom: 0.0, right: inset)
    }
}
