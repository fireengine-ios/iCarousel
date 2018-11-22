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
    @IBOutlet var premiumListViews: [PremiumListView]!
    
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
    func configure(with price: String, types: [PremiumListType]) {
        leavePremiumHeaderView.configure(with: price)
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
    
    private func setup() {
        leavePremiumHeaderView.delegate = self
    }
    
}

 //MARK: - LeavePremiumHeaderViewDelegate
extension LeavePremiumView: LeavePremiumHeaderViewDelegate {
    func onLeavePremiumTap() {
        delegate?.onLeavePremiumTap()
    }
}
