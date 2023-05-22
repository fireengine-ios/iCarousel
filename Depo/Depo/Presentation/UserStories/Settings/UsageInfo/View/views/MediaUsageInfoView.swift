//
//  MediaUsageInfoView.swift
//  Depo_LifeTech
//
//  Created by Raman Harhun on 3/29/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class MediaUsageInfoView: UIView {
    
    enum MediaType {
        case photo
        case video
        case music
        case docs
        
        var formatString: String {
            switch self {
            case .photo:
                return TextConstants.usageInfoPhotos
            case .video:
                return TextConstants.usageInfoVideos
            case .music:
                return TextConstants.usageInfoSongs
            case .docs:
                return TextConstants.usageInfoDocuments
            }
        }
        
        var icon: UIImage {
            switch self {
            case .photo:
                return Image.iconGalleryPhoto.image
            case .video:
                return Image.iconVideo.image
            case .music:
                return Image.iconMusicWhite.image
            case .docs:
                return Image.iconFileEmptyWhite.image
            }
        }
    }
    
    private let volumeLabel = UILabel()
    private let volumeIcon = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    //MARK: Utility Methods(Private)
    private func setup() {
        addSubview(volumeLabel)
        addSubview(volumeIcon)
        
        setupDesign()
        setupConstraints()
    }
    
    private func setupDesign() {
        volumeLabel.text = ""
        volumeLabel.textAlignment = .center
        volumeLabel.textColor = AppColor.label.color
        volumeLabel.font = .appFont(.regular, size: 15)
        volumeLabel.numberOfLines = 0
    }
    
    private func setupConstraints() {
        volumeLabel.translatesAutoresizingMaskIntoConstraints = false
        volumeIcon.translatesAutoresizingMaskIntoConstraints = false
        
        volumeIcon.topAnchor.constraint(equalTo: topAnchor).activate()
        volumeIcon.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        
        volumeLabel.topAnchor.constraint(equalTo: volumeIcon.bottomAnchor, constant: 4).isActive = true
        volumeLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        volumeLabel.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
    }
    
    //MARK: Utility Methods(Public)
    func configure(type: MediaType, count: Int?, volume: Int64?) {
        
        let countType = String(format: type.formatString, count ?? 0).components(separatedBy: " ")
        
        guard let countStr = countType.first,
              let typeStr = countType.last,
              let volume = volume else { return }
        
        volumeLabel.text = countStr + "\n" + typeStr + "\n" + volume.bytesString
        volumeIcon.image = type.icon
    }
}
