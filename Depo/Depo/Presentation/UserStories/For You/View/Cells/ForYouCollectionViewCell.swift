//
//  ForYouCollectionViewCell.swift
//  Depo
//
//  Created by Burak Donat on 23.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

class ForYouCollectionViewCell: UICollectionViewCell {
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let gradient = CAGradientLayer()

    @IBOutlet private weak var thumbnailImage: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.numberOfLines = 2
            newValue.font = .appFont(.medium, size: 14)
            newValue.textColor = .white
        }
    }
    
    @IBOutlet private weak var hiddenIcon: UIImageView! {
        willSet {
            newValue.image = Image.iconHideUnselect.image.withRenderingMode(.alwaysTemplate)
            newValue.tintColor = .white
        }
    }
    
    @IBOutlet private weak var emptyAlbumView: UIView! {
        willSet {
            newValue.isHidden = true
            newValue.layer.borderWidth = 1
            newValue.layer.cornerRadius = 5
            newValue.layer.borderColor = AppColor.darkTint.cgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGradientLayer()
    }
    
    func configure(with wrapData: WrapData, currentView: ForYouSections) {
        titleLabel.text = wrapData.name
        hiddenIcon.isHidden = currentView != .hidden
        
        switch currentView {
        case .places, .things, .albums:
            titleLabel.isHidden = false
        default:
            gradient.removeFromSuperlayer()
            titleLabel.isHidden = true
        }
        
        if currentView == .hidden {
            blurView.frame = thumbnailImage.bounds
            thumbnailImage.addSubview(blurView)
        } else {
            blurView.removeFromSuperview()
        }
        
        switch wrapData.patchToPreview {
        case .remoteUrl(let url):
            thumbnailImage.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
    
    func configureAlbum(with album: AlbumItem) {
        titleLabel.text = album.name
        titleLabel.isHidden = false
        hiddenIcon.isHidden = true
        
        switch album.preview?.patchToPreview {
        case .remoteUrl(let url):
            emptyAlbumView.isHidden = url != nil
            thumbnailImage.sd_setImage(with: url, completed: nil)
        default:
            break
        }
    }
    
    func configure(with data: InstapickAnalyze) {
        gradient.removeFromSuperlayer()
        titleLabel.isHidden = true
        hiddenIcon.isHidden = true
        thumbnailImage.sd_setImage(with: data.fileInfo?.metadata?.mediumUrl, completed: nil)
    }
    
    private func addGradientLayer() {
        gradient.frame = thumbnailImage.bounds
        let startColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        let endColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        gradient.colors = [startColor, endColor]
        thumbnailImage.layer.insertSublayer(gradient, at: 0)
    }
}
