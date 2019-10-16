//
//  PremiumHeaderView.swift
//  Depo_LifeTech
//
//  Created by Timafei Harhun on 11/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PremiumHeaderViewDelegate: class {
    func onBecomePremiumTap()
}

final class PremiumHeaderView: UIView {
    
    weak var delegate: PremiumHeaderViewDelegate?

    @IBOutlet private weak var premiumHeaderImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var premiumButton: GradientPremiumButton!
    
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
    func configure(with title: String,
                   price: String?,
                   description: String,
                   isHiddenTitleImageView: Bool?,
                   titleEdgeInsets: UIEdgeInsets) {
        titleLabel.text = title

        subtitleLabel.attributedText = getAttributeText(with: description, price: price)
        
        premiumHeaderImageView.isHidden = isHiddenTitleImageView ?? false
        premiumButton.titleEdgeInsets = titleEdgeInsets
    }
    
    func addSelectedAmination() {
        premiumButton.addSingleSelectedAnimation()
    }
    
    // MARK: Utility methods(Private)
    private func setup() {        
        setupDesign()
        
        premiumHeaderImageView.image = UIImage(named: "crownPremiumIcon")
        premiumButton.setTitle(TextConstants.becomePremiumMember, for: .normal)
    }
    
    private func setupView() {
        let nibNamed = String(describing: PremiumHeaderView.self)
        Bundle(for: PremiumHeaderView.self).loadNibNamed(nibNamed, owner: self, options: nil)
        guard let view = view else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func setupDesign() {
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 20)
        titleLabel.textColor = ColorConstants.darkText
        
        subtitleLabel.font = UIFont.TurkcellSaturaMedFont(size: 20)
        subtitleLabel.textColor = ColorConstants.darkText

        premiumButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 18)
    }
    
    private func getAttributeText(with text: String, price: String?) -> NSMutableAttributedString {
        let range = (text as NSString).range(of: price ?? "")
        let attr: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: UIFont.TurkcellSaturaBolFont(size: 18),
                                                        NSAttributedStringKey.foregroundColor: UIColor.lrTealish]
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(attr, range: range)
        return attributedString
    }
    
    // MARK: Actions
    @IBAction private func onBecomePrepiumTap(_ sender: Any) {
        delegate?.onBecomePremiumTap()
    }
        
}
