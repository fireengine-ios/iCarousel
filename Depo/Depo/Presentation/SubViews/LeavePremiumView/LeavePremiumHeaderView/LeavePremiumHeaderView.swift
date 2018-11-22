//
//  LeavePremiumHeaderView.swift
//  Depo
//
//  Created by Harbros 3 on 11/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol LeavePremiumHeaderViewDelegate: class {
    func onLeavePremiumTap()
}

final class LeavePremiumHeaderView: UIView {
    
    weak var delegate: LeavePremiumHeaderViewDelegate?
    
    @IBOutlet private weak var leavePremiumImageView: UIImageView!
    @IBOutlet private weak var leavePremiumButton: UIButton!
    @IBOutlet private weak var priceLabel: UILabel!
    
    @IBOutlet private var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    // MARK: Utility methods(Public)
    func configure(with price: String) {
        priceLabel.text = price
    }
    
    // MARK: Utility methods(Private)
    private func setup() {
        leavePremiumImageView.image = UIImage(named: "crownPremiumIcon")
        leavePremiumButton.setTitle(TextConstants.leavePremiumMember, for: .normal)
        setupDesign()
    }
    
    private func setupView() {
        let nibNamed = String(describing: LeavePremiumHeaderView.self)
        Bundle(for: LeavePremiumHeaderView.self).loadNibNamed(nibNamed, owner: self, options: nil)
        guard let view = view else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func setupDesign() {
        priceLabel.font = UIFont.TurkcellSaturaBolFont(size: 22)
        priceLabel.textColor = UIColor.lrTealish
        
        leavePremiumButton.setTitleColor(.white, for: .normal)
        leavePremiumButton.backgroundColor = ColorConstants.darcBlueColor
        leavePremiumButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
        leavePremiumButton.layer.masksToBounds = true
        leavePremiumButton.layer.cornerRadius = 15
    }
    
    // MARK: Actions
    @IBAction private func onLeavePremiumTap(_ sender: Any) {
        delegate?.onLeavePremiumTap()
    }
    
}
