//
//  SpotifyCollectionViewCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SpotifyCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet private weak var selectionView: UIView!
    @IBOutlet private weak var selectionImageView: UIImageView!
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 2
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.charcoalGrey
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.charcoalGrey.withAlphaComponent(0.5)
            newValue.font = UIFont.TurkcellSaturaFont(size: 16)
        }
    }
    @IBOutlet private weak var arrowImageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            selectionImageView.image = UIImage(named: isSelected ? "selected" : "notSelected")
        }
    }
    
    private var isSelectionMode: Bool = false {
        didSet {
            selectionView.isHidden = !isSelectionMode
        }
    }
    
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionImageView.image = UIImage(named: "notSelected")
        contentView.backgroundColor = .white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageManager?.cancelImageLoading()
        imageView.image = nil
        uuid = nil
    }
    
    func setup(with playlist: SpotifyPlaylist) {
        titleLabel.text = playlist.name
        subtitleLabel.text = "\(playlist.count) songs"
        arrowImageView.isHidden = playlist.count == 0
        setImage(with: playlist.image)
    }
    
    func setup(with track: SpotifyTrack) {
        titleLabel.text = track.name
        subtitleLabel.text = track.artistName
        arrowImageView.isHidden = true
        setImage(with: track.image)
    }
    
    func setSelectionMode(_ selectionMode: Bool, animation: Bool) {
        UIView.animate(withDuration: animation ? 0.1 : 0) {
            self.isSelectionMode = selectionMode
        }
    }
    
    private func setImage(with image: SpotifyImage?) {
        guard let url = image?.url else {
            return
        }
        
        let cacheKey = url.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        uuid = cellImageManager?.uniqueId
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                guard let image = image, let uuid = self.uuid, uuid == uniqueId else {
                    return
                }
                self.imageView.image = image
            }
        }
        
        cellImageManager?.loadImage(thumbnailUrl: nil, url: url, completionBlock: imageSetBlock)
    }
}
