//
//  SingleThumbnailAlbumCell.swift
//  Depo
//
//  Created by Aleksandr on 5/11/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import SDWebImage

final class SingleThumbnailAlbumCell: SimpleSliderCell {
    
    @IBOutlet private var noItemsBackgroundImage: UIImageView! {
        willSet {
            newValue.contentMode = .center
        }
    }
    
    @IBOutlet private var thumbnailsContainer: UIView!
    
    @IBOutlet private var thumbnail: UIImageView! {
        willSet {
            newValue.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet private weak var name: UILabel! {
        didSet {
            name.text = " "
            name.font = .appFont(.medium, size: 12)
            name.textColor = AppColor.label.color
        }
    }
    
    private let downloader = ImageDownloder()
    private var url: URL?
    
    //MARK: -
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func reset() {
        thumbnail?.image = nil
        if let unwrapedURL = url {
            downloader.cancelRequest(path: unwrapedURL)
            url = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnail?.contentMode = .scaleAspectFill
        thumbnail?.clipsToBounds = true
        thumbnail?.backgroundColor = UIColor.lightGray.lighter(by: 20.0)
        
        setupAccessibility()
    }
    
    override func setup(withItem item: SliderItem) {
        name.text = item.name
        accessibilityLabel = item.name
                
        guard let firstThubnail = item.previewItems?.first,
            case let .remoteUrl(pathURL) = firstThubnail else {
                ///thumbnail.image might be more suited for this.
                noItemsBackgroundImage.image = item.placeholderImage
                return
        }
        downloader.getImage(patch: pathURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.thumbnail.image = image
                self?.thumbnailsContainer.isHidden = false
                self?.url = nil
            }
        }
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .none
    }
}

