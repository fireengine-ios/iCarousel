//
//  SubscriptionsPolicyView.swift
//  Depo
//
//  Created by Andrei Novikau on 2/28/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class SubscriptionsPolicyView: UIView {

    private let policyHeaderSize: CGFloat = Device.isIpad ? 15 : 13
    private let policyTextSize: CGFloat = Device.isIpad ? 13 : 10
    
    private lazy var policyTextView: UITextView = {
        let textView = UITextView(frame: bounds)
        
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = ColorConstants.textLightGrayColor.cgColor
        textView.layer.borderWidth = 1
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPolicy()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPolicy()
    }
    
    private func setupPolicy() {
        addSubview(policyTextView)
        policyTextView.translatesAutoresizingMaskIntoConstraints = false
        policyTextView.pinToSuperviewEdges()
        
        let attributedString = NSMutableAttributedString(string: TextConstants.packagesPolicyHeader,
                                                         attributes: [.foregroundColor: ColorConstants.textGrayColor,
                                                                      .font: UIFont.TurkcellSaturaBolFont(size: policyHeaderSize)])
        
        let policyText = RouteRequests.isBillo ? TextConstants.packagesPolicyBilloText : TextConstants.packagesPolicyText
        
        let policyAttributedString = NSMutableAttributedString(string: "\n\n" + policyText,
                                                               attributes: [.foregroundColor: ColorConstants.textGrayColor,
                                                                            .font: UIFont.TurkcellSaturaRegFont(size: policyTextSize)])
        attributedString.append(policyAttributedString)

        let termsAttributedString = NSMutableAttributedString(string: TextConstants.termsOfUseLinkText,
                                                              attributes: [.link: TextConstants.NotLocalized.termsOfUseLink,
                                                                           .font: UIFont.TurkcellSaturaRegFont(size: policyTextSize)])
        attributedString.append(termsAttributedString)
        
        policyTextView.attributedText = attributedString
        policyTextView.delegate = self
        
        layoutIfNeeded()
    }
}

// MARK: - UITextViewDelegate
extension SubscriptionsPolicyView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == TextConstants.NotLocalized.termsOfUseLink {
            let router = RouterVC()
            let controller = router.termsOfUseScreen
            router.pushViewController(viewController: controller)
            return true
        }
        UIApplication.shared.openSafely(URL)
        return true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        UIApplication.shared.openSafely(URL)
        return UIApplication.shared.canOpenURL(URL)
    }
}
