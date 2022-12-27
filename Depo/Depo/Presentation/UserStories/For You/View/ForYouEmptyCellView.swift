//
//  ForYouEmptyCellView.swift
//  Depo
//
//  Created by Burak Donat on 1.08.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol ForYouEmptyCellViewDelegate: AnyObject {
    func navigateTo(view: ForYouSections)
}

class ForYouEmptyCellView: UIView, NibInit {
    
    weak var delegate: ForYouEmptyCellViewDelegate?
    private var currentView: ForYouSections?
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 3
            newValue.textColor = AppColor.label.color
            newValue.font = .appFont(.regular, size: 12)
        }
    }
    
    @IBOutlet private weak var emptyViewButton: RoundedButton! {
        willSet {
            newValue.backgroundColor = AppColor.forYouButton.color
            newValue.setTitle("", for: .normal)
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.setTitleColor(UIColor.white, for: .normal)
            newValue.setTitleColor(UIColor.white, for: .highlighted)
        }
    }
    
    @IBAction func onEmptyViewButton(_ sender: RoundedButton) {
        if let view = currentView {
            delegate?.navigateTo(view: view)
        }
    }
    
    func configure(with view: ForYouSections) {
        currentView = view
        emptyViewButton.setTitle(view.buttonText, for: .normal)
        descriptionLabel.text = view.emptyText
        emptyViewButton.isHidden = !(view == .photopick || view == .albums || view == .story)
    }

}
