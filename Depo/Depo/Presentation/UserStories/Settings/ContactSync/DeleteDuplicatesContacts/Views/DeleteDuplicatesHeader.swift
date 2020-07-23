//
//  DeleteDuplicatesHeader.swift
//  Depo
//
//  Created by Andrei Novikau on 5/25/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class DeleteDuplicatesHeader: UIView, NibInit {
    
    @IBOutlet private weak var contentView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.toolbarTintColor
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
        }
    }
    
    func setup(with count: Int) {
        let string = String(format: TextConstants.deleteDuplicatesTopLabel, count)
        
        let attributedString = NSMutableAttributedString(string: string, attributes: [.foregroundColor: ColorConstants.duplicatesGray,
                                                                                      .font: UIFont.TurkcellSaturaMedFont(size: 20)])
        
        let range = (string as NSString).range(of: "\(count)")
        attributedString.addAttributes([.font: UIFont.TurkcellSaturaBolFont(size: 20)], range: range)
        
        titleLabel.attributedText = attributedString
    }
}
