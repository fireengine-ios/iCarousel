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
    }
    
    private let countLabel = UILabel()
    private let volumeLabel = UILabel()
    private static let distance: CGFloat = 2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    //MARK: Utility Methods(Private)
    private func setup() {
        self.addSubview(countLabel)
        self.addSubview(volumeLabel)
        
        setupDesign()
        setupConstraints()
    }
    
    private func setupDesign() {
        volumeLabel.text = ""
        volumeLabel.textAlignment = .right
        volumeLabel.textColor = UIColor.lrTealish
        volumeLabel.font = UIFont.GTAmericaStandardRegularFont(size: 16)
        
        countLabel.text = ""
        countLabel.textAlignment = .right
        countLabel.textColor = ColorConstants.textGrayColor.color
        countLabel.font = UIFont.GTAmericaStandardRegularFont(size: 16)
    }
    
    private func setupConstraints() {
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        volumeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        volumeLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        volumeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        volumeLabel.bottomAnchor.constraint(equalTo: countLabel.topAnchor,
                                            constant: MediaUsageInfoView.distance).isActive = true
        
        countLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        countLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    //MARK: Utility Methods(Public)
    func configure(type: MediaType, count: Int?, volume: Int64?) {
        volumeLabel.text = volume?.bytesString
        countLabel.text = String(format: type.formatString, count ?? 0)
    }
}
