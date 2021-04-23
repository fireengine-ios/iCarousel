//
//  CustomScrollIndicator.swift
//  Depo
//
//  Created by Andrei Novikau on 12/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class CustomScrollIndicator: UIView {

    @IBOutlet private weak var sectionView: UIView!
    @IBOutlet private weak var sectionLabel: UILabel!
    @IBOutlet private weak var topOffsetConstraint: NSLayoutConstraint!
    
    var sectionTitle = "" {
        didSet {
            sectionLabel.text = sectionTitle
        }
    }
    
    var titleOffset: CGFloat = 0 {
        didSet {
            topOffsetConstraint.constant = titleOffset
            layoutIfNeeded()
        }
    }
    
    private var isIndicatorHidden: Bool {
        get {
            return sectionView.alpha == 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurate()
    }
    
    private func configurate() {
        if let view = Bundle.main.loadNibNamed("CustomScrollIndicator", owner: self, options: nil)?.first as? UIView {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }

        sectionView.clipsToBounds = true
        sectionView.layer.cornerRadius = 5
        sectionView.backgroundColor = ColorConstants.blueColor.color
        sectionLabel.textColor = .white
        sectionLabel.font = UIFont.GTAmericaStandardMediumFont(size: 12)
        titleOffset = NumericConstants.defaultCustomScrollIndicatorOffset
        isUserInteractionEnabled = false
    }
    
    func changeHiddenState(to hidden: Bool, animated: Bool = true) {        
        if isIndicatorHidden != hidden {
            layer.removeAllAnimations()
            UIView.animate(withDuration: animated ? NumericConstants.animationDuration : 0) {
                self.sectionView.alpha = hidden ? 0 : 1
            }
        }
    }
}
