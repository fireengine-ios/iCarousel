//
//  OverlayStickerViewControllerDesigner.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/20/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class OverlayStickerViewControllerDesigner: NSObject {
    
    @IBOutlet private  weak var stickersView: UIView! {
        willSet {
            newValue.addBorder(side: .bottom, thickness: 1, color: ColorConstants.stickerBorderColor)
            newValue.addBorder(side: .top, thickness: 1, color: ColorConstants.stickerBorderColor)
        }
    }
    
    @IBOutlet private weak var stickersCollectionView: UICollectionView! {
        willSet {
            newValue.backgroundColor = .clear
            newValue.contentInset = UIEdgeInsets(topBottom: 0, rightLeft: 15)
            newValue.register(nibCell: StickerCollectionViewCell.self)
            if let layout = newValue.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
            }
        }
    }
    
    @IBOutlet private weak var undoButtonView: UIView! {
        willSet {
            newValue.addBorder(side: .left, thickness: 1, color: ColorConstants.stickerBorderColor)
            newValue.addBorder(side: .bottom, thickness: 1, color: ColorConstants.stickerBorderColor)

            newValue.backgroundColor = .clear
        }
    }
    
}
