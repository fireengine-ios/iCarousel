//
//  SmartAlbumCell.swift
//  Depo
//
//  Created by Andrei Novikau on 3/25/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import SDWebImage

class SmartAlbumCell: SimpleSliderCell {
    
    @IBOutlet var noItemsBackgroundImage: UIImageView! {
        willSet {
            newValue.layer.borderWidth = 1.0
            newValue.contentMode = .center
        }
    }
    
    @IBOutlet var thumbnailsContainer: UIView! {
        willSet {
            newValue.backgroundColor = .white
        }
    }
    
    @IBOutlet private var thumbnailTopLeft: UIImageView!
    @IBOutlet private var thumbnailTopRight: UIImageView!
    @IBOutlet private var thumbnailBottomLeft: UIImageView!
    @IBOutlet private var thumbnailBottomRight: UIImageView!
    
    private lazy var thumnbails = [thumbnailTopLeft, thumbnailTopRight,
                                   thumbnailBottomLeft, thumbnailBottomRight]
    
    @IBOutlet weak var name: UILabel! {
        didSet {
            name.text = " "
            name.font = UIFont.TurkcellSaturaMedFont(size: 14)
            name.textColor = ColorConstants.darkText
        }
    }
    
    private let downloader = ImageDownloder()

    //MARK: -
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func reset() {
        for thumbnail in thumnbails {
            thumbnail?.image = nil
        }
        urls.compactMap {$0}.forEach { downloader.cancelRequest(path: $0) }
        urls.removeAll()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for thumbnail in thumnbails {
            thumbnail?.contentMode = .scaleAspectFill
            thumbnail?.clipsToBounds = true
            thumbnail?.backgroundColor = UIColor.lightGray.lighter(by: 20.0)
        }
        
        setupAccessibility()
    }
    
    override func setup(withItem item: SliderItem) {
        name.text = item.name
        accessibilityLabel = item.name
        
        noItemsBackgroundImage.layer.borderColor = item.type?.placeholderBorderColor ?? UIColor.white.cgColor
        
        guard let previews = item.previewItems, !previews.isEmpty else {
            noItemsBackgroundImage.image = item.placeholderImage
            thumbnailsContainer.isHidden = true
            return
        }
        
        thumbnailsContainer.isHidden = false
        noItemsBackgroundImage.image = nil
        
        updateThumbnails(with: previews, placeholders: item.previewPlaceholders)
    }
    
    private var urls = [URL?]()
    private func updateThumbnails(with previews: [PathForItem], placeholders: [UIImage?]) {
        for i in 0..<thumnbails.count {
            let placeholder = placeholders.count > i ? placeholders[i] : nil
            if case let .some(.remoteUrl(url)) = previews[safe: i] {
                urls.append(url)
                downloader.getImage(patch: url) { [weak self] image in
                    self?.thumnbails[i]?.image = image
                    self?.urls.remove(url)
                }
            } else {
                thumnbails[i]?.image = placeholder
            }
        }
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitNone
    }
}
