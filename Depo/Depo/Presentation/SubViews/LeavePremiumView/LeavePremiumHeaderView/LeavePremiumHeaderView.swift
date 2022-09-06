//
//  LeavePremiumHeaderView.swift
//  Depo
//
//  Created by Harbros 3 on 11/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol LeavePremiumHeaderViewDelegate: AnyObject {
    func onLeavePremiumTap()
}

final class LeavePremiumHeaderView: UIView {
        
    @IBOutlet private weak var topMessageLabel: UILabel!
    @IBOutlet private weak var detailsLabel: UILabel!
    
    @IBOutlet private var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupDesign()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: Utility methods(Public)
    
    func setupTexts(with type: LeavePremiumType) {
        topMessageLabel.text = type.topMessage
        detailsLabel.text = type.detailMessage
    }
    
    // MARK: Utility methods(Private)
    
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
        topMessageLabel.font = .appFont(.medium, size: 14)
        topMessageLabel.textColor = AppColor.label.color
        
        detailsLabel.font = .appFont(.regular, size: 12)
        detailsLabel.textColor = AppColor.label.color
    }
}
