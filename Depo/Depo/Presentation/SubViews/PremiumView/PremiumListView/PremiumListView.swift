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
    
    var allTypes: [PremiumListType] {
        return [.backup, .removeDuplicate, .faceRecognition, .placeRecognition, .objectRecognition]
    }
}

final class PremiumListView: UIView {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private var view: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
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
    private func commonInit() {
        Bundle(for: PremiumListView.self).loadNibNamed(String.init(describing: PremiumListView.self), owner: self, options: nil)
        guard let view = view else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func setup() {
        setStyle()
    }
    
    private func setStyle() {
        titleLabel.font = UIFont.TurkcellSaturaMedFont(size: C.Font.size)
        titleLabel.textColor = ColorConstants.darkText
    }

}

// MARK: - Constants
private enum C {
    enum Font {
        static let size: CGFloat = 15
    }
}
