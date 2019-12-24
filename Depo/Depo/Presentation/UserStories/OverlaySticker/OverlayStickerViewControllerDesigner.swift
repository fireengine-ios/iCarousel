//
//  OverlayStickerViewControllerDesigner.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/20/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class OverlayStickerViewControllerDesigner: NSObject {
    
    @IBOutlet private weak var stickersCollectionView: UICollectionView! {
        willSet {
            newValue.layer.borderColor = ColorConstants.stickerBorderColor.cgColor
            newValue.layer.borderWidth = 1
            newValue.backgroundColor = .clear
            newValue.contentInset = UIEdgeInsets(topBottom: 0, rightLeft: 5)
            newValue.register(nibCell: StickerCollectionViewCell.self)
            if let layout = newValue.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
            }
        }
    }
    
    @IBOutlet private weak var undoButtonView: UIView! {
        willSet {
            newValue.layer.borderColor = ColorConstants.stickerBorderColor.cgColor
            newValue.layer.borderWidth = 1
            newValue.backgroundColor = .clear
        }
    }
    
}
