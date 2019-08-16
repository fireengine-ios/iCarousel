//
//  SpotifyPlaylistCollectionViewCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

protocol SpotifyPlaylistCellDelegate: LBCellsDelegate {
    func onSelect(cell: SpotifyPlaylistCollectionViewCell)
    func onDeselect(cell: SpotifyPlaylistCollectionViewCell)
}

final class SpotifyPlaylistCollectionViewCell: BaseCollectionViewCell {
    
    private enum Constants {
        enum imageLeftOffset {
            static let selectionMode: CGFloat = 50
            static let defaultMode: CGFloat = 18
        }
    }
    
    @IBOutlet private weak var selectionButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "notSelected"), for: .normal)
            newValue.setImage(UIImage(named: "selected"), for: .selected)
            newValue.setImage(UIImage(named: "selected"), for: .highlighted)
            newValue.setImage(UIImage(named: "notSelected"), for: [.highlighted, .selected])
            newValue.addTarget(self, action: #selector(onSelectionButton(_:)), for: .touchUpInside)
            
            //TODO: remove when set correct images
            newValue.imageEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        }
    }
    
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
    @IBOutlet private var imageLeftOffset: NSLayoutConstraint!
    
    private weak var cellDelegate: SpotifyPlaylistCellDelegate?
    override weak var delegate: LBCellsDelegate? {
        didSet {
            if let compatableValue = delegate as? SpotifyPlaylistCellDelegate {
                cellDelegate = compatableValue
            }
        }
    }
    
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    
    private var isSelectionStateActive = false
    var isHiddenArrow = false {
        didSet {
            arrowImageView.isHidden = isHiddenArrow
        }
    }
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = .white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        uuid = nil
    }
    
    func setup(with item: SpotifyObject, delegate: SpotifyPlaylistCellDelegate, isSelected: Bool) {
        selectionButton.isSelected = isSelected
        self.delegate = delegate
        
        if let playlist = item as? SpotifyPlaylist {
            titleLabel.text = playlist.name
            subtitleLabel.text = String(format: TextConstants.Spotify.Playlist.songsCount, playlist.count)
            arrowImageView.isHidden = isHiddenArrow
            loadImage(item: item, placeholder: UIImage(named: "playlist")!)
        } else if let track = item as? SpotifyTrack {
            titleLabel.text = track.name
            subtitleLabel.text = track.artistName
            arrowImageView.isHidden = true
            loadImage(item: track, placeholder: UIImage(named: "playlist_track")!)
        }
    }
    
    func setSeletionMode(_ isActive: Bool, animated: Bool) {
        isSelectionStateActive = isActive
        if !isActive {
            selectionButton.isSelected = false
        }
        UIView.animate(withDuration: animated ? NumericConstants.setImageAnimationDuration : 0) {
            self.selectionButton.isHidden = !isActive
            self.imageLeftOffset.constant = isActive ? Constants.imageLeftOffset.selectionMode : Constants.imageLeftOffset.defaultMode
            self.layoutIfNeeded()
        }
    }
    
    private func loadImage(item: SpotifyObject, placeholder: UIImage) {
        if let spotifyUrl = item.image?.url {
            imageView.sd_setImage(with: spotifyUrl, placeholderImage: placeholder)
        } else if let imagePathUrl = item.imagePath {
            let cacheKey = imagePathUrl.byTrimmingQuery
            cellImageManager = CellImageManager.instance(by: cacheKey)
            
            if uuid == cellImageManager?.uniqueId {
                /// image will not be loaded
                return
            }
            
            uuid = cellImageManager?.uniqueId
            imageView.image = placeholder
            
            let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
                DispatchQueue.main.async {
                    guard let image = image, let uuid = self?.uuid, uuid == uniqueId else {
                        return
                    }
                    self?.imageView.image = image
                }
            }
            
            cellImageManager?.loadImage(thumbnailUrl: nil, url: imagePathUrl, completionBlock: imageSetBlock)
        } else {
            imageView.image = placeholder
        }
    }
    
    
    // MARK: - Actions
    
    @objc private func onSelectionButton(_ sender: UIButton) {
        reverseSelected()
    }
    
    func reverseSelected() {
        selectionButton.isSelected.toggle()
        if selectionButton.isSelected {
            cellDelegate?.onSelect(cell: self)
        } else {
            cellDelegate?.onDeselect(cell: self)
        }
    }
}
