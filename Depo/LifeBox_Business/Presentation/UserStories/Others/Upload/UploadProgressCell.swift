//
//  UploadProgressCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 26.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class UploadProgressCell: UICollectionViewCell {

    @IBOutlet private weak var progressStatusView: UIView!
    
    @IBOutlet private weak var thumbnail: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet private weak var fileName: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .GTAmericaStandardRegularFont(size: 12)
            newValue.textColor = ColorConstants.Text.labelTitle
        }
    }
    
    @IBOutlet private weak var fileSize: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .GTAmericaStandardRegularFont(size: 11)
            newValue.textColor = ColorConstants.Text.textFieldText
        }
    }
    
    @IBOutlet private weak var removeButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.setImage(UIImage(named: "cancelButton"), for: .normal)
        }
    }
    
    @IBOutlet private weak var separator: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.separator
        }
    }
    
    
    //MARK: - Public
    
    func setup(with item: WrapData) {
        
    }
    
    //MARK: - Private
    
    @IBAction private func onRemoveTapped(_ sender: Any) {
        //
    }
    
}
