//
//  PremiumListView.swift
//  Depo_LifeTech
//
//  Created by Timafei Harhun on 11/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum PremiumListType {
    case backup
    case removeDuplicate
    case faceRecognition
    case placeRecognition
    case objectRecognition
    case unlimitedPhotopick
    case additionalData
    
    static var allTypes: [PremiumListType] {
        return [.backup, .removeDuplicate, .faceRecognition, .placeRecognition, .objectRecognition, .unlimitedPhotopick, .additionalData]
    }
}

final class PremiumListView: UIView {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private var view: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    // MARK: Utility methods(Public)
    func configure(with title: String, image: UIImage) {
        titleLabel.text = title
        iconImageView.image = image
    }
    
    // MARK: Utility methods(Private)
    private func setupView() {
        let nibNamed = String(describing: PremiumListView.self)
        Bundle(for: PremiumListView.self).loadNibNamed(nibNamed, owner: self, options: nil)
        guard let view = view else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func setup() {
        setupDesign()
    }
    
    private func setupDesign() {
        titleLabel.font = UIFont.TurkcellSaturaMedFont(size: 15)
        titleLabel.textColor = ColorConstants.darkText
    }

}
