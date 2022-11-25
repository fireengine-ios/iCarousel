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
            newValue.backgroundColor = AppColor.background.color
        }
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        willSet {
            newValue.image = Image.iconBackupContactMain.image
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.numberOfLines = 0
            newValue.lineBreakMode = .byWordWrapping
            newValue.font = .appFont(.regular, size: 14)
            newValue.textColor = AppColor.label.color
        }
    }
    
    func setup(with count: Int) {
        let string = String(format: TextConstants.deleteDuplicatesTopLabel, count)
        let font = UIFont.appFont(.regular, size: 14)
        let color = AppColor.label.color
        let attributedString = NSMutableAttributedString(string: string, attributes: [.foregroundColor: color,
                                                                                      .font: font])
        
        let range = (string as NSString).range(of: "\(count)")
        attributedString.addAttributes([.font: font], range: range)
        
        titleLabel.text = string
    }
}
