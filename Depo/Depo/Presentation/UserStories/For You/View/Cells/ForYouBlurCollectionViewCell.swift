//
//  ForYouBlurCollectionViewCell.swift
//  Depo
//
//  Created by Burak Donat on 29.10.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class ForYouBlurCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var thumbnailImage: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var hiddenIcon: UIImageView! {
        willSet {
            newValue.image = Image.iconHideUnselect.image.withRenderingMode(.alwaysTemplate)
            newValue.tintColor = .white
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addBlurView()
    }
    
    func configure(with wrapData: WrapData) {
        switch wrapData.patchToPreview {
        case .remoteUrl(let url):
            thumbnailImage.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
    
    private func addBlurView() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = thumbnailImage.bounds
        thumbnailImage.addSubview(blurView)
    }
}
