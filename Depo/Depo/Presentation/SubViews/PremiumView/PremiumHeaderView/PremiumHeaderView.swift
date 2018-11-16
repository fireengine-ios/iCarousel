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
        
        commonInit()
    }
    
    // MARK: Utility methods(Public)
    func configure(with title: String, price: String) {
        titleLabel.text = title
        
        let description = TextConstants.useFollowingPremiumMembership + " \(price) /\(TextConstants.month)" + " \(TextConstants.additionalDataStoragePackage)"
        subtitleLabel.attributedText = getAttributeText(with: description)
    }

    
    // MARK: Utility methods(Private)
    private func setup() {        
        setStyle()
        
        premiumButton.addSelectedAnimation()
        
        premiumHeaderImageView.image = UIImage(named: "crownPremiumIcon")
    }
    
    private func commonInit() {
        Bundle(for: PremiumHeaderView.self).loadNibNamed(String.init(describing: PremiumHeaderView.self), owner: self, options: nil)
        guard let view = view else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func setStyle() {
        titleLabel.font = UIFont.TurkcellSaturaBolFont(size: C.Font.titleLabelSize)
        titleLabel.textColor = ColorConstants.darkText
        
        subtitleLabel.font = UIFont.TurkcellSaturaMedFont(size: C.Font.subtitleLabelSize)
        subtitleLabel.textColor = ColorConstants.darkText
    }
    
    private func getAttributeText(with text: String) -> NSMutableAttributedString {
        let range = (description as NSString).range(of: "\(text) /\(TextConstants.month)")
        let attr: [NSAttributedStringKey: AnyObject] = [NSAttributedStringKey.font: UIFont.TurkcellSaturaBolFont(size: C.Font.priceSize),
                                                        NSAttributedStringKey.foregroundColor: UIColor.lrTealish]
        
        let attributedString = NSMutableAttributedString(string: description)
        attributedString.addAttributes(attr, range: range)
        return attributedString
    }
    
    // MARK: Actions
    @IBAction private func onBecomePrepiumTap(_ sender: Any) {
        delegate?.onBecomePremiumTap()
    }
    
}

// MARK: - Constants
private enum C {
    enum Font {
        static let titleLabelSize: CGFloat = 20
        static let subtitleLabelSize: CGFloat = 20
        static let priceSize: CGFloat = 18
    }
}
