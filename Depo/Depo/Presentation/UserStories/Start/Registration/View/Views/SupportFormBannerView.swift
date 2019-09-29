//
//  FAQBannerView.swift
//  Depo
//
//  Created by Darya Kuliashova on 9/20/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

enum SupportBannerViewType {
    case support
    case faq
    
    var text: String {
        switch self {
        case .support:
            return TextConstants.signupSupportInfo
        case .faq:
            return TextConstants.signupFAQInfo
        }
    }
    
    var gradientColors: [CGColor] {
        switch self {
        case .support:
            return [ColorConstants.alertBlueGradientStart.cgColor,
                    ColorConstants.alertBlueGradientEnd.cgColor]
        case .faq:
            return [ColorConstants.alertOrangeAndBlueGradientStart.cgColor,
                    ColorConstants.alertOrangeAndBlueGradientEnd.cgColor]
        }
    }
}

protocol SupportFormBannerViewDelegate: class {
    func supportFormBannerViewDidClick(_ bannerView: SupportFormBannerView)
}

final class SupportFormBannerView: UIView, NibInit {
    @IBOutlet private weak var messageLabel: UILabel!

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    weak var delegate: SupportFormBannerViewDelegate?
    
    var type: SupportBannerViewType? {
        didSet {
            setupGradient()
            messageLabel.text = type?.text
        }
    }
    
    var shouldShowPicker = false
    
    var picker = UIPickerView()
    var toolBar = UIToolbar()
    
    override var canBecomeFirstResponder: Bool {
        return shouldShowPicker
    }
    
    override var inputView: UIView? {
        return picker
    }
    
    override var inputAccessoryView: UIView? {
        return toolBar
    }
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
        
        layer.cornerRadius = 4
    }

    private func setupGradient() {
        guard let gradientLayer = layer as? CAGradientLayer else {
            assertionFailure()
            return
        }

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = type?.gradientColors
    }
    
    // MARK: - Actions
    
    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        delegate?.supportFormBannerViewDidClick(self)
    }
}
