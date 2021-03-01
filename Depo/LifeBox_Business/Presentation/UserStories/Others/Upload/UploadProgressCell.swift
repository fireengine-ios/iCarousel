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
            newValue.font = .GTAmericaStandardRegularFont(size: 12)
            newValue.textColor = ColorConstants
        }
    }
    
    @IBOutlet private weak var fileSize: UILabel! {
        willSet {
            
        }
    }
    
    @IBOutlet private weak var removeButton: UIButton! {
        willSet {
            
        }
    }
    
    
    @IBAction private func onRemoveTapped(_ sender: Any) {
        
    }
    
}
