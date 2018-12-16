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
}

final class PremiumView: UIView {
    
    weak var delegate: PremiumViewDelegate?

    @IBOutlet private var view: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var premiumHeaderView: PremiumHeaderView!
    
    @IBOutlet private var premiumListViews: [PremiumListView]!
    
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
                   isNeedScroll: Bool = true) {
        scrollView.isScrollEnabled = isNeedScroll
        premiumHeaderView.configure(with: title, price: price, description: description, isHiddenTitleImageView: isHiddenTitleImageView, titleEdgeInsets: titleEdgeInsets)
        for premiumListView in premiumListViews.enumerated() {
            switch types[premiumListView.offset] {
            case .backup:
                premiumListView.element.configure(with: TextConstants.backUpOriginalQuality, image: UIImage(named: "backupPremiumIcon") ?? UIImage())
            case .removeDuplicate:
                premiumListView.element.configure(with: TextConstants.removeDuplicateContacts, image: UIImage(named: "removeDuplicatePremiumIcon") ?? UIImage())
            case .faceRecognition:
                premiumListView.element.configure(with: TextConstants.faceRecognitionToReach, image: UIImage(named: "faceImagePremiumIcon") ?? UIImage())
            case .placeRecognition:
                premiumListView.element.configure(with: TextConstants.placeRecognitionToBeam, image: UIImage(named: "placeRecognitionPremiumIcon") ?? UIImage())
            case .objectRecognition:
                premiumListView.element.configure(with: TextConstants.objectRecognitionToRemember, image: UIImage(named: "objectRecognitionPremiumIcon") ?? UIImage())
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
    
}

// MARK: - PremiumHeaderViewDelegate
extension PremiumView: PremiumHeaderViewDelegate {
    func onBecomePremiumTap() {
        delegate?.onBecomePremiumTap()
    }
}
