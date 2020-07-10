//
//  PremiumView.swift
//  Depo_LifeTech
//
//  Created by Timafei Harhun on 11/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol PremiumViewDelegate: class {
    func onBecomePremiumTap()
    func showTermsOfUse()
    func openLink(with url: URL)
}

final class PremiumView: UIView {
    
    weak var delegate: PremiumViewDelegate?

    @IBOutlet private var view: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var premiumHeaderView: PremiumHeaderView!
    @IBOutlet weak var policyTextView: UITextView!
    
    @IBOutlet private var premiumListViews: [PremiumListView]!
    
    private let policyHeaderSize: CGFloat = Device.isIpad ? 15 : 13
    private let policyTextSize: CGFloat = Device.isIpad ? 13 : 10

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
                   types: [PremiumListType],
                   isHiddenTitleImageView: Bool? = false,
                   titleEdgeInsets: UIEdgeInsets,
                   isNeedScroll: Bool = true,
                   isNeedPolicy: Bool,
                   isTurkcell: Bool) {
        scrollView.isScrollEnabled = isNeedScroll
        
        if isNeedPolicy {
            setupPolicy()
        }
        
        premiumHeaderView.configure(with: title, price: price, description: description, isHiddenTitleImageView: isHiddenTitleImageView, titleEdgeInsets: titleEdgeInsets)
        for premiumListView in premiumListViews.enumerated() {
            if let type = types[safe: premiumListView.offset] {
                premiumListView.element.configure(with: type.message, image: type.image ?? UIImage())
            } else {
                premiumListView.element.isHidden = true
            }
        }
    }
    
    func addSelectedAmination() {
        premiumHeaderView.addSelectedAmination()
    }
    
    // MARK: Utility methods(Private)
    private func setupView() {
        let nibNamed = String(describing: PremiumView.self)
        Bundle(for: PremiumView.self).loadNibNamed(nibNamed, owner: self, options: nil)
        guard let view = view else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func setup() {
        premiumHeaderView.delegate = self        
    }
    
    private func setupPolicy() {
        let attributedString = NSMutableAttributedString(
            string: TextConstants.packagesPolicyHeader,
            attributes: [.foregroundColor: ColorConstants.textGrayColor,
                         .font: UIFont.TurkcellSaturaBolFont(size: policyHeaderSize)])
        
        var policyText = RouteRequests.isBillo ? TextConstants.packagesPolicyBilloText : TextConstants.packagesPolicyText
        
        let policyAttributedString = NSMutableAttributedString(
            string: "\n\n" + policyText,
            attributes: [.foregroundColor: ColorConstants.textGrayColor,
                         .font: UIFont.TurkcellSaturaRegFont(size: policyTextSize)])
        attributedString.append(policyAttributedString)
        
        let termsAttributedString = NSMutableAttributedString(
            string: TextConstants.termsOfUseLinkText,
            attributes: [.link: TextConstants.NotLocalized.termsOfUseLink,
                         .font: UIFont.TurkcellSaturaRegFont(size: policyTextSize)])
        attributedString.append(termsAttributedString)
        
        policyTextView.attributedText = attributedString
        policyTextView.clipsToBounds = true
        policyTextView.layer.cornerRadius = 5
        policyTextView.layer.borderColor = ColorConstants.textLightGrayColor.cgColor
        policyTextView.layer.borderWidth = 1
    }
}

// MARK: - PremiumHeaderViewDelegate
extension PremiumView: PremiumHeaderViewDelegate {
    func onBecomePremiumTap() {
        delegate?.onBecomePremiumTap()
    }
}

// MARK: - UITextViewDelegate
extension PremiumView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == TextConstants.NotLocalized.termsOfUseLink {
            DispatchQueue.toMain {
                self.delegate?.showTermsOfUse()
            }
        } else {
            delegate?.openLink(with: URL)
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        delegate?.openLink(with: URL)
        return true
    }
}
