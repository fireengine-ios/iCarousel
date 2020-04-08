//
//  LeavePremiumView.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/22/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol LeavePremiumViewDelegate: class {
    func onLeavePremiumTap()
}

final class LeavePremiumView: UIView {

    weak var delegate: LeavePremiumViewDelegate?

    @IBOutlet private weak var leavePremiumHeaderView: LeavePremiumHeaderView!
    @IBOutlet weak var leavePremiumButton: InsetsButton!
    @IBOutlet var premiumListViews: [PremiumListView]!
    
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
    func configure(with type: LeavePremiumType, hideButton: Bool = false) {
        leavePremiumButton.isHidden = hideButton
        leavePremiumButton.setTitle(type.buttonTitle, for: .normal)

        let types = type.listTypes(isTurkcell: SingletonStorage.shared.isTurkcellUser)
        
        for premiumListView in premiumListViews.enumerated() {
            if let type = types[safe: premiumListView.offset] {
                premiumListView.element.configure(with: type.message, image: type.image ?? UIImage())
            } else {
                premiumListView.element.isHidden = true
            }
        }
        
        leavePremiumHeaderView.setupTexts(with: type)
    }
    
    // MARK: Utility methods(Private)
    private func setupView() {
        let nibNamed = String(describing: LeavePremiumView.self)
        Bundle(for: LeavePremiumView.self).loadNibNamed(nibNamed, owner: self, options: nil)
        guard let view = view else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func setupDesign() {
        leavePremiumButton.setTitleColor(.white, for: .normal)
        leavePremiumButton.backgroundColor = ColorConstants.darkBlueColor
        leavePremiumButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
        leavePremiumButton.layer.masksToBounds = true
        leavePremiumButton.layer.cornerRadius = 15
    }
    
    // MARK: Actions
    @IBAction func onLeavePremiumTap(_ sender: Any) {
        delegate?.onLeavePremiumTap()
    }
}
