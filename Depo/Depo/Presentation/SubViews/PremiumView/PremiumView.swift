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

    @IBOutlet private  var view: UIView!
    @IBOutlet private weak var premiumHeaderView: PremiumHeaderView!
    
    @IBOutlet private var premiumListViews: [PremiumListView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    // MARK: Utility methods(Public)
    func configure(with title: String, price: String, types: [PremiumListType]) {
        premiumHeaderView.configure(with: title, price: price)
        for premiumListView in premiumListViews.enumerated() {
            switch types[premiumListView.offset] {
            case .backup:
                premiumListView.element.configure(with: "Back up with Original Quality", image: UIImage(named: "backupPremiumIcon") ?? UIImage())
            case .removeDuplicate:
                premiumListView.element.configure(with: "Remove Duplicate Contacts from Your Directory", image: UIImage(named: "removeDuplicatePremiumIcon") ?? UIImage())
            case .faceRecognition:
                premiumListView.element.configure(with: "Face Recognition to reach your loved one's memories", image: UIImage(named: "faceImagePremiumIcon") ?? UIImage())
            case .placeRecognition:
                premiumListView.element.configure(with: "Place Recognition to beam you up to the memories", image: UIImage(named: "placeRecognitionPremiumIcon") ?? UIImage())
            case .objectRecognition:
                premiumListView.element.configure(with: "Object Recognition to remember with things you love", image: UIImage(named: "objectRecognitionPremiumIcon") ?? UIImage())
            }
        }
    }
    
    // MARK: Utility methods(Private)
    private func commonInit() {
        Bundle(for: PremiumView.self).loadNibNamed(String(describing: PremiumView.self), owner: self, options: nil)
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
